from fastapi import FastAPI, Request, Depends, HTTPException, Form, File, UploadFile
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from starlette.middleware.sessions import SessionMiddleware
from authlib.integrations.starlette_client import OAuth
from sqlmodel import Session, select, create_engine, func
from sqlalchemy.orm import selectinload
from uvicorn.middleware.proxy_headers import ProxyHeadersMiddleware
from .core.config import settings
from .models.models import User, UserRole, Activity, Competency, Promotion, Group, Resource, Announcement, LearningOutcome, EssentialComponent, ActivityGroup, ActivityGroupStudentLink
from .services.matrix_service import matrix_service
from .services.ai_service import ai_service
import os, httpx, json, asyncio, uuid

app = FastAPI(title="Skills Hub Remaster")
static_dir = os.path.join(os.path.dirname(__file__), "static")
app.mount("/static", StaticFiles(directory=static_dir), name="static")

app.add_middleware(ProxyHeadersMiddleware, trusted_hosts="*")
app.add_middleware(SessionMiddleware, secret_key=settings.SECRET_KEY, session_cookie="skills_hub_session", max_age=3600*24*7, same_site="none", https_only=True)

engine = create_engine(settings.DATABASE_URL)
templates = Jinja2Templates(directory=os.path.join(os.path.dirname(__file__), "templates"))

@app.on_event("startup")
def on_startup():
    from .models.models import SQLModel
    SQLModel.metadata.create_all(engine)

oauth = OAuth()
oauth.register(
    name='keycloak',
    client_id=settings.KEYCLOAK_CLIENT_ID,
    client_secret=settings.KEYCLOAK_CLIENT_SECRET,
    authorize_url=f"https://auth.{settings.DOMAIN}/realms/{settings.KEYCLOAK_REALM}/protocol/openid-connect/auth",
    access_token_url=f"http://remaster_keycloak:8080/realms/{settings.KEYCLOAK_REALM}/protocol/openid-connect/token",
    userinfo_endpoint=f"http://remaster_keycloak:8080/realms/{settings.KEYCLOAK_REALM}/protocol/openid-connect/userinfo",
    jwks_uri=f"http://remaster_keycloak:8080/realms/{settings.KEYCLOAK_REALM}/protocol/openid-connect/certs",
    client_kwargs={'scope': 'openid profile email'},
)

async def get_current_db_user(request: Request):
    user_session = request.session.get('user')
    if not user_session: return None
    username = user_session.get('preferred_username')
    with Session(engine) as session:
        db_user = session.exec(select(User).where(User.ldap_uid == username)).first()
        if not db_user:
            db_user = User(ldap_uid=username, full_name=user_session.get('name', username), email=user_session.get('email', f"{username}@univ-lehavre.fr"), role=UserRole.GUEST, roles_json='["GUEST"]')
            session.add(db_user); session.commit(); session.refresh(db_user)
        return db_user

# --- VIEWS ---

@app.get("/")
async def index(request: Request):
    db_user = await get_current_db_user(request)
    if not db_user: return RedirectResponse(url='/login')
    active_role = request.session.get('active_role') or db_user.role.value
    with Session(engine) as session:
        stats = {"users": session.exec(select(func.count(User.id))).one(), "activities": session.exec(select(func.count(Activity.id))).one(), "resources": session.exec(select(func.count(Resource.id))).one()}
        announcements = session.exec(select(Announcement).order_by(Announcement.created_at.desc()).limit(5)).all()
        dashboard_data = {"recent_activities": session.exec(select(Activity).order_by(Activity.id.desc()).limit(5)).all(), "users_count": stats["users"], "sae_count": stats["activities"], "resources_count": stats["resources"]}
        news = [{"sender": a.author_uid, "content": f"**{a.title}**<br>{a.content}", "timestamp": a.created_at} for a in announcements]
        return templates.TemplateResponse(request, "dashboard.html", {"request": request, "user": db_user, "active_role": active_role, "stats": stats, "data": dashboard_data, "news": news})

@app.get("/referentiel")
async def referentiel(request: Request):
    db_user = await get_current_db_user(request)
    if not db_user: return RedirectResponse(url='/login')
    active_role = request.session.get('active_role') or db_user.role.value
    with Session(engine) as session:
        competencies = session.exec(select(Competency).options(selectinload(Competency.learning_outcomes).selectinload(LearningOutcome.activities), selectinload(Competency.learning_outcomes).selectinload(LearningOutcome.resources), selectinload(Competency.essential_components)).order_by(Competency.code)).all()
        activities = session.exec(select(Activity).options(selectinload(Activity.learning_outcomes)).order_by(Activity.code)).all()
        resources = session.exec(select(Resource).options(selectinload(Resource.learning_outcomes)).order_by(Resource.code)).all()
        pathways = session.exec(select(Competency.pathway).distinct()).all()
        return templates.TemplateResponse(request, "referentiel.html", {"request": request, "user": db_user, "active_role": active_role, "competencies": competencies, "activities": activities, "resources": resources, "pathways": pathways})

@app.get("/effectifs")
async def effectifs(request: Request):
    db_user = await get_current_db_user(request)
    if not db_user: return RedirectResponse(url='/login')
    active_role = request.session.get('active_role') or db_user.role.value
    with Session(engine) as session:
        promotions = session.exec(select(Promotion).options(selectinload(Promotion.users), selectinload(Promotion.groups))).all()
        return templates.TemplateResponse(request, "effectifs.html", {"request": request, "user": db_user, "active_role": active_role, "promos_by_level": {1: next((p for p in promotions if p.entry_year == 2026), None), 2: next((p for p in promotions if p.entry_year == 2025), None), 3: next((p for p in promotions if p.entry_year == 2024), None)}, "total_users": sum(len(p.users) for p in promotions)})

@app.get("/admin/activities")
async def admin_activities(request: Request):
    db_user = await get_current_db_user(request)
    if not db_user: return RedirectResponse(url='/login')
    active_role = request.session.get('active_role') or db_user.role.value
    with Session(engine) as session:
        activities = session.exec(select(Activity).options(selectinload(Activity.responsible_user)).order_by(Activity.code)).all()
        resources = session.exec(select(Resource).order_by(Resource.code)).all()
        teachers = session.exec(select(User).where(User.role != UserRole.STUDENT).order_by(User.full_name)).all()
        return templates.TemplateResponse(request, "admin_activities.html", {
            "request": request, "user": db_user, "active_role": active_role, 
            "activities": activities, "resources": resources, "teachers": teachers
        })

@app.get("/ai-assistant")
async def ai_assistant_view(request: Request):
    db_user = await get_current_db_user(request)
    if not db_user: return RedirectResponse(url='/login')
    active_role = request.session.get('active_role') or db_user.role.value
    return templates.TemplateResponse(request, "ai_assistant.html", {"request": request, "user": db_user, "active_role": active_role})

@app.get("/admin/users")
async def admin_users(request: Request):
    db_user = await get_current_db_user(request)
    if not db_user: return RedirectResponse(url='/login')
    active_role = request.session.get('active_role') or db_user.role.value
    with Session(engine) as session:
        all_users = session.exec(select(User).where(User.role != UserRole.STUDENT).order_by(User.full_name)).all()
        return templates.TemplateResponse(request, "admin_users.html", {"request": request, "user": db_user, "active_role": active_role, "all_users": all_users})

@app.get("/settings")
async def settings_view(request: Request):
    db_user = await get_current_db_user(request)
    if not db_user: return RedirectResponse(url='/login')
    active_role = request.session.get('active_role') or db_user.role.value
    return templates.TemplateResponse(request, "settings.html", {"request": request, "user": db_user, "active_role": active_role})

@app.get("/synchro-scodoc")
async def synchro_scodoc(request: Request):
    db_user = await get_current_db_user(request)
    if not db_user: return RedirectResponse(url='/login')
    active_role = request.session.get('active_role') or db_user.role.value
    return templates.TemplateResponse(request, "dispatch_students.html", {"request": request, "user": db_user, "active_role": active_role})

@app.get("/admin/activities/{act_id}")
async def admin_activity_detail(request: Request, act_id: int):
    db_user = await get_current_db_user(request)
    if not db_user: return RedirectResponse(url='/login')
    active_role = request.session.get('active_role') or db_user.role.value
    with Session(engine) as session:
        act = session.exec(select(Activity).options(selectinload(Activity.learning_outcomes).selectinload(LearningOutcome.resources), selectinload(Activity.activity_groups).selectinload(ActivityGroup.students), selectinload(Activity.activity_groups).selectinload(ActivityGroup.tutor)).where(Activity.id == act_id)).first()
        pedigree = [{"code": ac.code, "label": ac.label, "resources": [{"code": r.code, "label": r.label, "responsible": r.responsible} for r in ac.resources]} for ac in act.learning_outcomes]
        lt = sorted(list(set([r["responsible"] for p in pedigree for r in p["resources"] if r["responsible"] and r["responsible"] != "(inconnu)"])))
        students = session.exec(select(User).join(Promotion).where(User.role == 'STUDENT', Promotion.entry_year == (2026 - act.level + 1))).all()
        return templates.TemplateResponse(request, "admin_activity_detail.html", {"request": request, "user": db_user, "active_role": active_role, "activity": act, "pedigree": pedigree, "linked_teachers": lt, "students": students})

# --- API ENDPOINTS ---

@app.get("/api/v1/admin/users/professors")
@app.get("/api/v1/admin/users/search")
async def admin_users_search(q: str = ""):
    results = []
    with Session(engine) as session:
        locals = session.exec(select(User).where(User.full_name.ilike(f"%{q}%") | User.ldap_uid.ilike(f"%{q}%")).limit(10)).all()
        for u in locals: results.append({"ldap_uid": u.ldap_uid, "full_name": u.full_name, "id": u.id})
    try:
        import psycopg2
        conn = psycopg2.connect(host="remaster_db_keycloak", database="keycloak", user="keycloak", password="keycloak_password")
        cur = conn.cursor(); cur.execute("SELECT username, first_name, last_name, email FROM user_entity WHERE (username ILIKE %s OR first_name ILIKE %s OR last_name ILIKE %s) LIMIT 10", (f"%{q}%", f"%{q}%", f"%{q}%"))
        for row in cur.fetchall():
            if not any(r["ldap_uid"] == row[0] for r in results):
                results.append({"ldap_uid": row[0], "full_name": f"{row[1]} {row[2]}".strip() or row[0], "email": row[3], "source": "keycloak"})
        cur.close(); conn.close()
    except: pass
    return results

@app.put("/api/v1/admin/users/{uid}/roles")
async def update_user_roles(uid: str, roles: list[str]):
    with Session(engine) as session:
        user = session.exec(select(User).where(User.ldap_uid == uid)).first()
        if user and roles: user.role = UserRole(roles[0]); user.roles_json = json.dumps(roles); session.add(user); session.commit()
    return {"status": "success"}

@app.get("/api/student/{ldap_uid}")
async def get_student_details(ldap_uid: str):
    with Session(engine) as session:
        s = session.exec(select(User).where(User.ldap_uid == ldap_uid)).first()
        if not s: return {"error": "Étudiant non trouvé"}
        return {
            "ldap_uid": s.ldap_uid,
            "full_name": s.full_name,
            "email": s.email,
            "nip": s.nip,
            "promotion_id": s.promotion_id,
            "group_id": s.group_id
        }

@app.get("/api/teacher/{ldap_uid}")
async def get_teacher_details(ldap_uid: str):
    with Session(engine) as session:
        t = session.exec(select(User).where(User.ldap_uid == ldap_uid)).first()
        if not t: return {"error": "Non trouvé"}
        res = session.exec(select(Resource).where((Resource.responsible_uid == t.ldap_uid) | (Resource.responsible == t.full_name))).all()
        global_acts = session.exec(select(Activity).where(Activity.responsible_id == t.id)).all()
        tutored_groups = session.exec(select(ActivityGroup).options(selectinload(ActivityGroup.activity), selectinload(ActivityGroup.students)).where(ActivityGroup.tutor_id == t.id)).all()
        return {"ldap_uid": t.ldap_uid, "full_name": t.full_name, "email": t.email, "phone": t.phone, "roles": t.roles_list, "managed_activities": [{"code": a.code, "label": a.label} for a in global_acts], "tutored_groups": [{"activity_code": g.activity.code, "group_name": g.name, "students": [s.full_name for s in g.students]} for g in tutored_groups], "resources": [{"code": r.code, "label": r.label} for r in res]}

@app.patch("/api/v1/dispatch/resources/{res_id}")
async def dispatch_resource_save(res_id: int, request: Request):
    data = await request.json(); uid = data.get("responsible_uid"); name = data.get("responsible")
    with Session(engine) as session:
        res = session.get(Resource, res_id)
        if res:
            teacher = session.exec(select(User).where(User.ldap_uid == uid)).first()
            if not teacher and uid:
                teacher = User(ldap_uid=uid, full_name=name or uid, role=UserRole.PROFESSOR, email=f"{uid}@univ-lehavre.fr"); session.add(teacher); session.commit(); session.refresh(teacher)
            if teacher: res.responsible_uid = teacher.ldap_uid; res.responsible = teacher.full_name; session.add(res); session.commit()
    return {"status": "success"}

@app.post("/api/v1/dispatch/auto-sync")
async def auto_sync_scodoc():
    try:
        async with httpx.AsyncClient(timeout=20.0) as client:
            h_resp = await client.get("http://host.docker.internal:8092/api/hierarchie")
            scodoc_data = h_resp.json()
            with Session(engine) as session:
                import psycopg2
                kc_conn = psycopg2.connect(host="remaster_db_keycloak", database="keycloak", user="keycloak", password="keycloak_password")
                kc_cur = kc_conn.cursor()
                for f_name, groups in scodoc_data.items():
                    year = 2026 if "2026" in f_name else 2025 if "2025" in f_name else 2024
                    promo = session.exec(select(Promotion).where(Promotion.entry_year == year)).first()
                    if not promo: continue
                    for g_name, students in groups.items():
                        group = session.exec(select(Group).where(Group.name == g_name, Group.promotion_id == promo.id)).first()
                        if not group: group = Group(name=g_name, promotion_id=promo.id); session.add(group); session.commit(); session.refresh(group)
                        for s in students:
                            email = s.get("email", "").lower(); uid = s.get("username")
                            if email:
                                kc_cur.execute("SELECT username FROM user_entity WHERE email = %s LIMIT 1", (email,))
                                row = kc_cur.fetchone()
                                if row: uid = row[0]
                            if uid:
                                user = session.exec(select(User).where(User.ldap_uid == uid)).first()
                                if not user: user = User(ldap_uid=uid, nip=str(s.get("nip")), full_name=f"{s.get('prenom')} {s.get('nom')}", email=email, role=UserRole.STUDENT, promotion_id=promo.id, group_id=group.id); session.add(user)
                session.commit(); kc_cur.close(); kc_conn.close()
        return {"status": "success"}
    except: return {"status": "error"}

@app.post("/admin/activities/{act_id}/responsible")
async def admin_activity_responsible(request: Request, act_id: int):
    f = await request.form(); resp_id = f.get("responsible_id"); uid = f.get("ldap_uid"); name = f.get("full_name")
    with Session(engine) as session:
        act = session.get(Activity, act_id)
        if act:
            t = session.get(User, int(resp_id)) if resp_id else session.exec(select(User).where(User.ldap_uid == uid)).first()
            if not t and uid: t = User(ldap_uid=uid, full_name=name or uid, role=UserRole.PROFESSOR, email=f"{uid}@univ-lehavre.fr"); session.add(t); session.commit(); session.refresh(t)
            if t: act.responsible_id = t.id; session.add(act); session.commit()
    return HTMLResponse(content="OK")

@app.post("/admin/activities/{act_id}/groups/add")
async def admin_activity_group_add(act_id: int):
    with Session(engine) as session:
        c = session.exec(select(func.count(ActivityGroup.id)).where(ActivityGroup.activity_id == act_id)).one()
        session.add(ActivityGroup(name=f"Groupe {c + 1}", activity_id=act_id)); session.commit()
    return RedirectResponse(url=f"/admin/activities/{act_id}", status_code=303)

@app.post("/admin/groups/{group_id}/tutor")
async def admin_group_tutor(request: Request, group_id: int):
    f = await request.form(); tid = f.get("tutor_id"); uid = f.get("ldap_uid"); name = f.get("full_name")
    with Session(engine) as session:
        g = session.get(ActivityGroup, group_id)
        if g:
            t = session.get(User, int(tid)) if tid else session.exec(select(User).where(User.ldap_uid == uid)).first()
            if not t and uid: t = User(ldap_uid=uid, full_name=name or uid, role=UserRole.PROFESSOR, email=f"{uid}@univ-lehavre.fr"); session.add(t); session.commit(); session.refresh(t)
            if t: g.tutor_id = t.id; session.add(g); session.commit()
    return HTMLResponse(content="OK")

@app.get("/api/v1/dispatch/groups/{group_id}/students")
async def get_group_students(group_id: int):
    with Session(engine) as session:
        users = session.exec(select(User).where(User.group_id == group_id)).all()
        return [{"ldap_uid": u.ldap_uid, "full_name": u.full_name} for u in users]

@app.get("/api/v1/dispatch/groups/all")
async def get_all_groups():
    with Session(engine) as session:
        groups = session.exec(select(Group)).all()
        return [{"id": g.id, "name": g.name, "pathway": g.pathway} for g in groups]

@app.patch("/api/v1/dispatch/students/{student_uid}/move")
async def move_student(student_uid: str, request: Request):
    data = await request.json(); target_id = data.get("target_group_id")
    with Session(engine) as session:
        user = session.exec(select(User).where(User.ldap_uid == student_uid)).first()
        if user: user.group_id = int(target_id); session.add(user); session.commit()
    return {"status": "success"}

@app.delete("/api/v1/dispatch/students/{student_uid}/remove-group")
async def remove_student_from_group(student_uid: str):
    with Session(engine) as session:
        user = session.exec(select(User).where(User.ldap_uid == student_uid)).first()
        if user: user.group_id = None; session.add(user); session.commit()
    return {"status": "success"}

@app.post("/ai/chat")
async def ai_chat(request: Request):
    db_user = await get_current_db_user(request)
    form_data = await request.form(); user_message = form_data.get("message")
    chat_id = await ai_service.create_chat(name=f"Chat {db_user.full_name}", dataset_ids=[ai_service.common_dataset_id], preprompt=db_user.ai_preprompt_general) or ai_service.default_chat_id
    sess_id = await ai_service.create_session(f"Sess {db_user.full_name}")
    ai_data = await ai_service.chat(chat_id, sess_id, user_message)
    return HTMLResponse(content=f'<div class="bg-white/10 p-6 rounded-3xl">{ai_data["answer"]}</div>')

@app.get("/ai/ged/list")
async def ai_ged_list(request: Request):
    db_user = await get_current_db_user(request)
    if not db_user or not db_user.ragflow_dataset_id: return HTMLResponse(content='Aucun document.')
    docs = await ai_service.list_documents(db_user.ragflow_dataset_id)
    html = "".join([f'<div class="p-3 bg-slate-50 rounded-xl border border-slate-100 mb-2">{d["name"]}</div>' for d in docs])
    return HTMLResponse(content=html or 'Aucun document.')

@app.post("/ai/ged/upload")
async def ai_ged_upload(request: Request):
    db_user = await get_current_db_user(request)
    form_data = await request.form(); upload_file = form_data.get("file")
    if not db_user.ragflow_dataset_id:
        db_user.ragflow_dataset_id = await ai_service.get_or_create_dataset(db_user.ldap_uid)
        with Session(engine) as session: session.add(db_user); session.commit(); session.refresh(db_user)
    content = await upload_file.read(); await ai_service.upload_document(db_user.ldap_uid, content, upload_file.filename)
    return HTMLResponse(content="OK")

@app.post("/settings/ai")
async def settings_ai_save(request: Request):
    db_user = await get_current_db_user(request)
    form_data = await request.form()
    with Session(engine) as session:
        user = session.get(User, db_user.id)
        user.ai_preprompt_general = form_data.get("ai_preprompt_general"); user.ai_preprompt_exercises = form_data.get("ai_preprompt_exercises"); user.ai_preprompt_course = form_data.get("ai_preprompt_course"); session.add(user); session.commit()
    return HTMLResponse(content="OK")

@app.get("/admin/ac-editor")
async def admin_ac_editor(request: Request):
    db_user = await get_current_db_user(request)
    if not db_user: return RedirectResponse(url='/login')
    active_role = request.session.get('active_role') or db_user.role.value
    if active_role != 'ADMIN': return RedirectResponse(url='/')
    with Session(engine) as session:
        acs = session.exec(select(LearningOutcome).options(selectinload(LearningOutcome.competency)).order_by(LearningOutcome.code)).all()
        return templates.TemplateResponse(request, "ac_editor.html", {"request": request, "user": db_user, "active_role": active_role, "learning_outcomes": acs})

@app.post("/admin/ac-editor-save")
async def admin_ac_save(request: Request):
    f = await request.form(); ac_id = int(f.get("ac_id"))
    with Session(engine) as session:
        ac = session.get(LearningOutcome, ac_id)
        if ac: ac.description = f.get("description"); session.add(ac); session.commit()
    return HTMLResponse(content="OK")

@app.get("/login")
async def login(request: Request):
    request.session.clear()
    return await oauth.keycloak.authorize_redirect(request, f"https://hub.{settings.DOMAIN}/auth")

@app.get("/auth")
async def auth(request: Request):
    try:
        token = await oauth.keycloak.authorize_access_token(request)
        request.session['user'] = dict(token.get('userinfo'))
        return RedirectResponse(url='/')
    except: return RedirectResponse(url='/login')

@app.get("/logout")
async def logout(request: Request):
    request.session.clear()
    return RedirectResponse(url=f"https://auth.{settings.DOMAIN}/realms/{settings.KEYCLOAK_REALM}/protocol/openid-connect/logout?client_id={settings.KEYCLOAK_CLIENT_ID}&post_logout_redirect_uri=https://hub.{settings.DOMAIN}/")

@app.get("/switch-role/{role}")
async def switch_role(request: Request, role: str):
    db_user = await get_current_db_user(request)
    if db_user: request.session['active_role'] = role
    return RedirectResponse(url='/')
