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

class AuthRequiredException(Exception):
    pass

@app.exception_handler(AuthRequiredException)
async def auth_exception_handler(request: Request, exc: AuthRequiredException):
    return RedirectResponse(url='/login')

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

async def require_auth(request: Request, user: User = Depends(get_current_db_user)):
    if not user:
        raise AuthRequiredException()
    return user

class RoleChecker:
    def __init__(self, allowed_roles: list[str]):
        self.allowed_roles = allowed_roles
    
    def __call__(self, request: Request, user: User = Depends(get_current_db_user)):
        if not user:
            raise AuthRequiredException()
        active_role = request.session.get('active_role') or user.role.value
        if active_role not in self.allowed_roles and "ADMIN" not in (user.roles_list or []):
            raise HTTPException(status_code=403, detail="Accès refusé : privilèges insuffisants")
        return user

# Dépendances réutilisables
admin_only = RoleChecker(["ADMIN"])
prof_or_admin = RoleChecker(["ADMIN", "PROFESSOR"])
any_auth = require_auth

# --- VIEWS ---

@app.get("/")
async def index(request: Request, user: User = Depends(require_auth)):
    active_role = request.session.get('active_role') or user.role.value
    with Session(engine) as session:
        stats = {"users": session.exec(select(func.count(User.id))).one(), "activities": session.exec(select(func.count(Activity.id))).one(), "resources": session.exec(select(func.count(Resource.id))).one()}
        dashboard_data = {"recent_activities": session.exec(select(Activity).order_by(Activity.id.desc()).limit(5)).all(), "users_count": stats["users"], "sae_count": stats["activities"], "resources_count": stats["resources"]}
        announcements = session.exec(select(Announcement).order_by(Announcement.created_at.desc()).limit(5)).all()
        news = [{"sender": a.author_uid, "content": f"**{a.title}**<br>{a.content}", "timestamp": a.created_at} for a in announcements]
        return templates.TemplateResponse(request, "dashboard.html", {"request": request, "user": user, "active_role": active_role, "stats": stats, "data": dashboard_data, "news": news})

@app.get("/referentiel")
async def referentiel(request: Request, user: User = Depends(require_auth)):
    active_role = request.session.get('active_role') or user.role.value
    with Session(engine) as session:
        competencies = session.exec(select(Competency).options(selectinload(Competency.learning_outcomes).selectinload(LearningOutcome.activities), selectinload(Competency.learning_outcomes).selectinload(LearningOutcome.resources), selectinload(Competency.essential_components)).order_by(Competency.code)).all()
        activities = session.exec(select(Activity).options(selectinload(Activity.learning_outcomes)).order_by(Activity.code)).all()
        resources = session.exec(select(Resource).options(selectinload(Resource.learning_outcomes)).order_by(Resource.code)).all()
        pathways = session.exec(select(Competency.pathway).distinct()).all()
        return templates.TemplateResponse(request, "referentiel.html", {"request": request, "user": user, "active_role": active_role, "competencies": competencies, "activities": activities, "resources": resources, "pathways": pathways})

@app.get("/effectifs")
async def effectifs(request: Request, user: User = Depends(require_auth)):
    active_role = request.session.get('active_role') or user.role.value
    with Session(engine) as session:
        promotions = session.exec(select(Promotion).options(selectinload(Promotion.users), selectinload(Promotion.groups))).all()
        return templates.TemplateResponse(request, "effectifs.html", {"request": request, "user": user, "active_role": active_role, "promos_by_level": {1: next((p for p in promotions if p.entry_year == 2026), None), 2: next((p for p in promotions if p.entry_year == 2025), None), 3: next((p for p in promotions if p.entry_year == 2024), None)}, "total_users": sum(len(p.users) for p in promotions)})

@app.get("/admin/activities")
async def admin_activities(request: Request, user: User = Depends(prof_or_admin)):
    active_role = request.session.get('active_role') or user.role.value
    with Session(engine) as session:
        activities = session.exec(select(Activity).options(selectinload(Activity.responsible_user)).order_by(Activity.code)).all()
        resources = session.exec(select(Resource).order_by(Resource.code)).all()
        teachers = session.exec(select(User).where(User.role != UserRole.STUDENT).order_by(User.full_name)).all()
        return templates.TemplateResponse(request, "admin_activities.html", {"request": request, "user": user, "active_role": active_role, "activities": activities, "resources": resources, "teachers": teachers})

@app.get("/ai-assistant")
async def ai_assistant_view(request: Request, user: User = Depends(require_auth)):
    return templates.TemplateResponse(request, "ai_assistant.html", {"request": request, "user": user, "active_role": request.session.get('active_role') or user.role.value})

@app.get("/admin/users")
async def admin_users(request: Request, user: User = Depends(admin_only)):
    active_role = request.session.get('active_role') or user.role.value
    with Session(engine) as session:
        all_users = session.exec(select(User).where(User.role != UserRole.STUDENT).order_by(User.full_name)).all()
        return templates.TemplateResponse(request, "admin_users.html", {"request": request, "user": user, "active_role": active_role, "all_users": all_users})

@app.get("/settings")
async def settings_view(request: Request, user: User = Depends(require_auth)):
    return templates.TemplateResponse(request, "settings.html", {"request": request, "user": user, "active_role": request.session.get('active_role') or user.role.value})

@app.get("/synchro-scodoc")
async def synchro_scodoc(request: Request, user: User = Depends(admin_only)):
    return templates.TemplateResponse(request, "dispatch_students.html", {"request": request, "user": user, "active_role": "ADMIN"})

@app.get("/admin/matrix")
async def admin_matrix(request: Request, user: User = Depends(admin_only)):
    active_role = request.session.get('active_role') or user.role.value
    with Session(engine) as session:
        announcements = session.exec(select(Announcement).order_by(Announcement.created_at.desc()).limit(10)).all()
        return templates.TemplateResponse(request, "admin_matrix.html", {"request": request, "user": user, "active_role": active_role, "announcements": announcements})

@app.post("/api/v1/admin/matrix/announce", dependencies=[Depends(admin_only)])
async def api_matrix_announce(request: Request, user: User = Depends(get_current_db_user)):
    data = await request.json()
    title = data.get("title")
    content = data.get("content")
    room_type = data.get("room", "general")
    priority = data.get("priority", "normal")
    
    room_id, event_id = await matrix_service.broadcast_announcement(title, content, room_type, priority)
    
    if event_id:
        with Session(engine) as session:
            ann = Announcement(title=title, content=content, author_uid=user.ldap_uid, matrix_event_id=event_id, matrix_room_id=room_id)
            session.add(ann)
            session.commit()
        return {"status": "success", "event_id": event_id}
    raise HTTPException(status_code=500, detail="Échec de l'envoi Matrix")

@app.post("/api/v1/admin/matrix/sync-rooms", dependencies=[Depends(admin_only)])
async def api_matrix_sync_rooms():
    created = 0
    with Session(engine) as session:
        promos = session.exec(select(Promotion)).all()
        for p in promos:
            room_name = f"BUT TC - Promo {p.entry_year}"
            # Logique simplifiée : on pourrait stocker le room_id dans la table Promotion
            room_id = await matrix_service.create_room(room_name, topic=f"Salon officiel de la promo {p.entry_year}")
            if room_id: created += 1
            
        groups = session.exec(select(Group)).all()
        for g in groups:
            room_id = await matrix_service.create_room(f"Groupe {g.name}", topic=f"Travaux dirigés - {g.name}")
            if room_id: created += 1
            
    return {"status": "success", "created": created}

@app.delete("/api/v1/admin/matrix/announcements/{id}", dependencies=[Depends(admin_only)])
async def api_matrix_delete_announcement(id: int):
    with Session(engine) as session:
        ann = session.get(Announcement, id)
        if ann:
            if ann.matrix_event_id and ann.matrix_room_id:
                await matrix_service.redact_event(ann.matrix_room_id, ann.matrix_event_id)
            session.delete(ann)
            session.commit()
            return {"status": "success"}
    raise HTTPException(status_code=404, detail="Annonce non trouvée")

# --- API ENDPOINTS ---

@app.post("/api/v1/dispatch/auto-sync", dependencies=[Depends(admin_only)])
async def auto_sync_scodoc():
    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            h_resp = await client.get("http://host.docker.internal:8092/api/hierarchie")
            scodoc_data = h_resp.json()
            with Session(engine) as session:
                import psycopg2
                kc_conn = psycopg2.connect(host=settings.KC_DB_HOST, database=settings.KC_DB_NAME, user=settings.KC_DB_USER, password=settings.KC_DB_PASS)
                kc_cur = kc_conn.cursor()
                
                for f_name, types in scodoc_data.items():
                    year = 2026 if "2026" in f_name or "BUT1" in f_name else 2025 if "2025" in f_name or "BUT2" in f_name else 2024
                    promo = session.exec(select(Promotion).where(Promotion.entry_year == year)).first()
                    if not promo: continue
                    
                    for t_name, groups in types.items():
                        for g_name, students in groups.items():
                            group = session.exec(select(Group).where(Group.name == g_name, Group.promotion_id == promo.id)).first()
                            if not group:
                                group = Group(name=g_name, promotion_id=promo.id, year=year, academic_year="2025-2026", formation_type=t_name)
                                session.add(group); session.commit(); session.refresh(group)
                            
                            for s in students:
                                email = s.get("email", "").lower()
                                uid = s.get("username")
                                
                                # RÉSOLUTION LDAP PROACTIVE (Insensible à la casse)
                                if email:
                                    kc_cur.execute("SELECT username FROM user_entity WHERE LOWER(email) = %s LIMIT 1", (email,))
                                else:
                                    # On cherche par nom/prénom en forçant la casse
                                    kc_cur.execute("SELECT username FROM user_entity WHERE LOWER(first_name) = %s AND LOWER(last_name) = %s LIMIT 1", (s.get("prenom", "").lower(), s.get("nom", "").lower()))
                                
                                kc_row = kc_cur.fetchone()
                                if kc_row: 
                                    uid = kc_row[0]
                                else:
                                    uid = f"nip_{s.get('nip')}" # Marqueur de maillage incomplet

                                user = session.exec(select(User).where(User.ldap_uid == uid)).first()
                                if not user:
                                    user = User(
                                        ldap_uid=uid, nip=str(s.get("nip")), 
                                        full_name=f"{s.get('prenom')} {s.get('nom')}", 
                                        email=email or f"{uid}@univ-lehavre.fr", 
                                        role=UserRole.STUDENT, promotion_id=promo.id, group_id=group.id
                                    )
                                    session.add(user)
                                else:
                                    user.group_id = group.id; user.promotion_id = promo.id; user.nip = str(s.get("nip")); session.add(user)
                session.commit(); kc_cur.close(); kc_conn.close()
        return {"status": "success"}
    except Exception as e: return {"status": "error", "detail": str(e)}

@app.get("/api/student/{ldap_uid}", dependencies=[Depends(prof_or_admin)])
async def get_student_details(ldap_uid: str):
    with Session(engine) as session:
        s = session.exec(select(User).where(User.ldap_uid == ldap_uid)).first()
        return {"ldap_uid": s.ldap_uid, "full_name": s.full_name, "email": s.email, "nip": s.nip} if s else {"error": "Non trouvé"}

@app.get("/api/v1/admin/users/professors", dependencies=[Depends(prof_or_admin)])
@app.get("/api/v1/admin/users/search", dependencies=[Depends(prof_or_admin)])
async def admin_users_search(q: str = ""):
    results = []
    with Session(engine) as session:
        locals = session.exec(select(User).where(User.full_name.ilike(f"%{q}%") | User.ldap_uid.ilike(f"%{q}%")).limit(10)).all()
        for u in locals: results.append({"ldap_uid": u.ldap_uid, "full_name": u.full_name, "id": u.id})
    try:
        import psycopg2
        conn = psycopg2.connect(host=settings.KC_DB_HOST, database=settings.KC_DB_NAME, user=settings.KC_DB_USER, password=settings.KC_DB_PASS)
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
            if not teacher and uid: teacher = User(ldap_uid=uid, full_name=name or uid, role=UserRole.PROFESSOR, email=f"{uid}@univ-lehavre.fr"); session.add(teacher); session.commit(); session.refresh(teacher)
            if teacher: res.responsible_uid = teacher.ldap_uid; res.responsible = teacher.full_name; session.add(res); session.commit()
    return {"status": "success"}

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

@app.delete("/api/v1/dispatch/groups/{group_id}")
async def delete_promo_group(group_id: int):
    with Session(engine) as session:
        group = session.get(Group, group_id)
        if group:
            session.exec(func.update(User).where(User.group_id == group_id).values(group_id=None))
            session.delete(group); session.commit()
    return {"status": "success"}

@app.post("/api/v1/dispatch/promotions/{promo_id}/groups/add")
async def add_promo_group(promo_id: int):
    with Session(engine) as session:
        count = session.exec(select(func.count(Group.id)).where(Group.promotion_id == promo_id)).one()
        session.add(Group(name=f"GR.{count+1} (FI)", promotion_id=promo_id, pathway="Tronc Commun", year=2026, academic_year="2025-2026", formation_type="FI"))
        session.commit()
    return RedirectResponse(url="/effectifs", status_code=303)

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

@app.get("/logout")
async def logout(request: Request):
    request.session.clear()
    return RedirectResponse(url=f"https://auth.{settings.DOMAIN}/realms/{settings.KEYCLOAK_REALM}/protocol/openid-connect/logout?client_id={settings.KEYCLOAK_CLIENT_ID}&post_logout_redirect_uri=https://hub.{settings.DOMAIN}/")

@app.get("/switch-role/{role}")
async def switch_role(request: Request, role: str):
    db_user = await get_current_db_user(request)
    if db_user: request.session['active_role'] = role
    return RedirectResponse(url='/')
