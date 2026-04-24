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

@app.get("/debug-static")
async def debug_static(): return {"exists": os.path.exists(os.path.join(static_dir, "medias", "logo-sh.svg"))}

app.add_middleware(ProxyHeadersMiddleware, trusted_hosts="*")
app.add_middleware(SessionMiddleware, secret_key=settings.SECRET_KEY, session_cookie="skills_hub_session", max_age=3600*24*7, same_site="lax", https_only=False)

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

@app.get("/")
async def index(request: Request):
    user = request.session.get('user')
    if not user: return RedirectResponse(url='/login')
    with Session(engine) as session:
        db_user = session.exec(select(User).where(User.ldap_uid == user['preferred_username'])).first()
        if not db_user: return RedirectResponse(url='/login')
        active_role = request.session.get('active_role') or db_user.role.value
        stats = {"users": session.exec(select(func.count(User.id))).one(), "activities": session.exec(select(func.count(Activity.id))).one(), "resources": session.exec(select(func.count(Resource.id))).one()}
        announcements = session.exec(select(Announcement).order_by(Announcement.created_at.desc()).limit(5)).all()
        dashboard_data = {"recent_activities": session.exec(select(Activity).order_by(Activity.id.desc()).limit(5)).all(), "users_count": stats["users"], "sae_count": stats["activities"], "resources_count": stats["resources"]}
        news = [{"sender": a.author_uid, "content": f"**{a.title}**<br>{a.content}", "timestamp": a.created_at} for a in announcements]
        return templates.TemplateResponse(request, "dashboard.html", {"request": request, "user": db_user, "active_role": active_role, "stats": stats, "data": dashboard_data, "news": news})

@app.get("/referentiel")
async def referentiel(request: Request):
    user_session = request.session.get('user')
    if not user_session: return RedirectResponse(url='/login')
    with Session(engine) as session:
        db_user = session.exec(select(User).where(User.ldap_uid == user_session['preferred_username'])).first()
        active_role = request.session.get('active_role') or db_user.role.value
        statement = select(Competency).options(selectinload(Competency.learning_outcomes).selectinload(LearningOutcome.activities), selectinload(Competency.learning_outcomes).selectinload(LearningOutcome.resources), selectinload(Competency.essential_components)).order_by(Competency.code)
        competencies = session.exec(statement).all()
        activities = session.exec(select(Activity).options(selectinload(Activity.learning_outcomes)).order_by(Activity.code)).all()
        resources = session.exec(select(Resource).options(selectinload(Resource.learning_outcomes)).order_by(Resource.code)).all()
        pathways = session.exec(select(Competency.pathway).distinct()).all()
        return templates.TemplateResponse(request, "referentiel.html", {"request": request, "user": db_user, "active_role": active_role, "competencies": competencies, "activities": activities, "resources": resources, "pathways": pathways})

@app.get("/effectifs")
async def effectifs(request: Request):
    user_session = request.session.get('user')
    if not user_session: return RedirectResponse(url='/login')
    with Session(engine) as session:
        db_user = session.exec(select(User).where(User.ldap_uid == user_session['preferred_username'])).first()
        if not db_user or (request.session.get('active_role') or db_user.role.value) != 'ADMIN': return RedirectResponse(url='/')
        promotions = session.exec(select(Promotion).options(selectinload(Promotion.users), selectinload(Promotion.groups))).all()
        current_year = 2026
        promos_by_level = {1: next((p for p in promotions if p.entry_year == current_year), None), 2: next((p for p in promotions if p.entry_year == current_year - 1), None), 3: next((p for p in promotions if p.entry_year == current_year - 2), None)}
        resources = session.exec(select(Resource).order_by(Resource.code)).all()
        teachers = session.exec(select(User).where(User.role != UserRole.STUDENT).order_by(User.full_name)).all()
        return templates.TemplateResponse(request, "effectifs.html", {"request": request, "user": db_user, "active_role": "ADMIN", "promos_by_level": promos_by_level, "total_users": sum(len(p.users) for p in promotions), "resources": resources, "teachers": teachers})

@app.get("/api/v1/admin/users/professors")
@app.get("/api/v1/admin/users/search")
async def admin_users_search(q: str = ""):
    results = []
    with Session(engine) as session:
        locals = session.exec(select(User).where(User.full_name.ilike(f"%{q}%") | User.ldap_uid.ilike(f"%{q}%")).limit(10)).all()
        for u in locals: results.append({"ldap_uid": u.ldap_uid, "full_name": u.full_name, "id": u.id})
    uids = [r["ldap_uid"] for r in results]
    try:
        import psycopg2
        conn = psycopg2.connect(host="db_keycloak", database="keycloak", user="keycloak", password="keycloak_password")
        cur = conn.cursor()
        cur.execute("SELECT username, first_name, last_name, email FROM user_entity WHERE (username ILIKE %s OR first_name ILIKE %s OR last_name ILIKE %s) AND username NOT IN %s LIMIT 10", (f"%{q}%", f"%{q}%", f"%{q}%", tuple(uids) if uids else ('',)))
        for row in cur.fetchall(): results.append({"ldap_uid": row[0], "full_name": f"{row[1]} {row[2]}".strip() or row[0], "email": row[3], "source": "keycloak"})
        cur.close(); conn.close()
    except: pass
    return results

@app.get("/api/teacher/{ldap_uid}")
async def get_teacher_details(ldap_uid: str):
    with Session(engine) as session:
        t = session.exec(select(User).where(User.ldap_uid == ldap_uid)).first()
        if not t: return {"error": "Non trouvé"}
        res = session.exec(select(Resource).where((Resource.responsible_uid == t.ldap_uid) | (Resource.responsible == t.full_name))).all()
        global_acts = session.exec(select(Activity).where(Activity.responsible_id == t.id)).all()
        tutored_groups = session.exec(select(ActivityGroup).options(selectinload(ActivityGroup.activity), selectinload(ActivityGroup.students)).where(ActivityGroup.tutor_id == t.id)).all()
        return {
            "ldap_uid": t.ldap_uid, "full_name": t.full_name, "email": t.email, "phone": t.phone, "roles": t.roles_list,
            "managed_activities": [{"code": a.code, "label": a.label, "type": a.type.value} for a in global_acts],
            "tutored_groups": [{"activity_code": g.activity.code, "group_name": g.name, "students": [s.full_name for s in g.students]} for g in tutored_groups],
            "resources": [{"code": r.code, "label": r.label} for r in res]
        }

@app.patch("/api/v1/dispatch/resources/{res_id}")
async def dispatch_resource_save(res_id: int, request: Request):
    data = await request.json(); uid = data.get("responsible_uid"); name = data.get("responsible")
    with Session(engine) as session:
        res = session.get(Resource, res_id)
        if res:
            teacher = session.exec(select(User).where(User.ldap_uid == uid)).first()
            if not teacher and name: teacher = session.exec(select(User).where(User.full_name == name)).first()
            if not teacher and uid and uid != name:
                teacher = User(ldap_uid=uid, full_name=name or uid, role=UserRole.PROFESSOR, email=f"{uid}@univ-lehavre.fr")
                session.add(teacher); session.commit(); session.refresh(teacher)
            if teacher: res.responsible_uid = teacher.ldap_uid; res.responsible = teacher.full_name; session.add(res); session.commit()
    return {"status": "success"}

@app.get("/synchro-scodoc")
async def synchro_scodoc(request: Request):
    user_session = request.session.get('user')
    if not user_session: return RedirectResponse(url='/login')
    with Session(engine) as session:
        db_user = session.exec(select(User).where(User.ldap_uid == user_session['preferred_username'])).first()
        scodoc_data = {"hierarchy": {}, "resources": []}
        try:
            async with httpx.AsyncClient(timeout=5.0) as client:
                h = await client.get("http://host.docker.internal:8092/api/hierarchie"); r = await client.get("http://host.docker.internal:8092/api/ressources")
                if h.status_code == 200: scodoc_data["hierarchy"] = h.json()
                if r.status_code == 200: scodoc_data["resources"] = r.json()
        except: pass
        return templates.TemplateResponse(request, "dispatch_students.html", {"request": request, "user": db_user, "active_role": "ADMIN", "scodoc": scodoc_data})

@app.get("/settings")
async def settings_view(request: Request):
    user_session = request.session.get('user')
    if not user_session: return RedirectResponse(url='/login')
    with Session(engine) as session:
        db_user = session.exec(select(User).where(User.ldap_uid == user_session['preferred_username'])).first()
        return templates.TemplateResponse(request, "settings.html", {"request": request, "user": db_user, "active_role": request.session.get('active_role') or db_user.role.value})

@app.get("/ai-assistant")
async def ai_assistant_view(request: Request):
    user_session = request.session.get('user')
    if not user_session: return RedirectResponse(url='/login')
    with Session(engine) as session:
        db_user = session.exec(select(User).where(User.ldap_uid == user_session['preferred_username'])).first()
        return templates.TemplateResponse(request, "ai_assistant.html", {"request": request, "user": db_user, "active_role": request.session.get('active_role') or db_user.role.value})

@app.post("/settings/ai")
async def settings_ai_save(request: Request):
    user_session = request.session.get('user')
    if not user_session: return HTMLResponse(content="Session expirée", status_code=401)
    form_data = await request.form()
    with Session(engine) as db_session:
        db_user = db_session.exec(select(User).where(User.ldap_uid == user_session['preferred_username'])).first()
        db_user.ai_preprompt_general = form_data.get("ai_preprompt_general"); db_user.ai_preprompt_exercises = form_data.get("ai_preprompt_exercises"); db_user.ai_preprompt_course = form_data.get("ai_preprompt_course"); db_session.add(db_user); db_session.commit()
    return HTMLResponse(content="OK")

@app.post("/ai/chat")
async def ai_chat(request: Request):
    user_session = request.session.get('user')
    if not user_session: return HTMLResponse(content="Session expirée", status_code=401)
    with Session(engine) as db_session:
        db_user = db_session.exec(select(User).where(User.ldap_uid == user_session['preferred_username'])).first()
        form_data = await request.form(); mode = form_data.get("mode", "general"); user_message = form_data.get("message"); ephe = form_data.get("ephemeral_file")
        pre = {"general": db_user.ai_preprompt_general or db_user.ai_preprompt, "exercices": db_user.ai_preprompt_exercises, "cours": db_user.ai_preprompt_course}
        final_pre = pre.get(mode, pre["general"]); ds = [ai_service.common_dataset_id]
        if db_user.ragflow_dataset_id: ds.append(db_user.ragflow_dataset_id)
        f_info = ""
        if ephe and hasattr(ephe, 'filename') and ephe.filename:
            t_ds = await ai_service.get_or_create_dataset(db_user.ldap_uid, is_temp=True)
            if t_ds:
                await ai_service.upload_document(db_user.ldap_uid, await ephe.read(), ephe.filename); ds.append(t_ds)
                f_info = f"\n[CONSIGNE_SYSTEME: Document joint '{ephe.filename}'.]\n"
        c_name = f"Assistant {db_user.full_name} ({mode})"
        chat_id = await ai_service.create_chat(name=c_name, dataset_ids=ds, preprompt=final_pre) or ai_service.default_chat_id
        sess_id = await ai_service.create_session(c_name if chat_id != ai_service.default_chat_id else ai_service.default_chat_name)
        ai_data = await ai_service.chat(chat_id, session_id=sess_id, message=f_info + user_message)
        msg_id = f"msg_{uuid.uuid4().hex[:8]}"
        html = f"""<div class="flex justify-end gap-4"><div class="bg-blue-600/20 p-6 rounded-[2.5rem] max-w-lg font-medium text-sm text-white">{user_message}</div><div class="w-10 h-10 bg-blue-600 rounded-xl flex items-center justify-center text-[10px] font-black shrink-0">MOI</div></div><div class="flex gap-4"><div class="w-10 h-10 bg-indigo-600 rounded-xl flex items-center justify-center shadow-lg shrink-0"><svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M12 8V4H8"/><rect width="16" height="12" x="4" y="8" rx="2"/><path d="M2 14h2"/><path d="M20 14h2"/><path d="M15 13v2"/><path d="M9 13v2"/></svg></div><div id="{msg_id}" class="bg-white/10 p-8 rounded-[2.5rem] max-w-3xl border border-white/5 prose-ai shadow-inner"><div class="animate-pulse flex gap-2"><div class="h-2 w-2 bg-white/20 rounded-full"></div><div class="h-2 w-2 bg-white/20 rounded-full"></div><div class="h-2 w-2 bg-white/20 rounded-full"></div></div></div></div><script>formatAndAnimateMessage("{msg_id}", `{ai_data["answer"].replace('`','\\`').replace('$','\\$')}`);</script>"""
        return HTMLResponse(content=html)

@app.get("/ai/ged/list")
async def ai_ged_list(request: Request):
    user_session = request.session.get('user')
    if not user_session: return HTMLResponse(content="")
    with Session(engine) as db_session:
        db_user = db_session.exec(select(User).where(User.ldap_uid == user_session['preferred_username'])).first()
        if not db_user or not db_user.ragflow_dataset_id: return HTMLResponse(content='<p class="text-[10px] text-slate-400 italic text-center p-4">Aucun document.</p>')
        docs = await ai_service.list_documents(db_user.ragflow_dataset_id)
        if not docs: return HTMLResponse(content='<p class="text-[10px] text-slate-400 italic text-center p-4">Aucun document.</p>')
        html = "".join([f'<div class="p-4 bg-slate-50 rounded-2xl border border-slate-100 flex items-center justify-between group hover:border-blue-200 transition-all"><div class="flex items-center gap-3 overflow-hidden"><div class="w-2 h-2 {"bg-emerald-500" if (str(d.get("run")) in ["2", "SUCCESS", "DONE"] or d.get("progress", 0) >= 1.0) else "bg-amber-500" if str(d.get("run")) in ["1", "RUNNING", "START"] else "bg-slate-300"} rounded-full shrink-0"></div><span class="text-[11px] font-bold text-slate-700 truncate">{d["name"]}</span></div></div>' for d in docs])
        return HTMLResponse(content=html)

@app.post("/ai/ged/upload")
async def ai_ged_upload(request: Request):
    user_session = request.session.get('user')
    if not user_session: return HTMLResponse(content="Session expirée", status_code=401)
    form_data = await request.form(); upload_file = form_data.get("file")
    with Session(engine) as db_session:
        db_user = db_session.exec(select(User).where(User.ldap_uid == user_session['preferred_username'])).first()
        if not db_user.ragflow_dataset_id:
            db_user.ragflow_dataset_id = await ai_service.get_or_create_dataset(db_user.ldap_uid); db_session.add(db_user); db_session.commit(); db_session.refresh(db_user)
        if db_user.ragflow_dataset_id:
            await ai_service.upload_document(db_user.ldap_uid, await upload_file.read(), upload_file.filename)
    return HTMLResponse(content="OK")

@app.get("/admin/users")
async def admin_users(request: Request):
    user_session = request.session.get('user')
    if not user_session: return RedirectResponse(url='/login')
    with Session(engine) as session:
        db_user = session.exec(select(User).where(User.ldap_uid == user_session['preferred_username'])).first()
        if not db_user or (request.session.get('active_role') or db_user.role.value) != 'ADMIN': return RedirectResponse(url='/')
        all_users = session.exec(select(User).where(User.role != UserRole.STUDENT).order_by(User.full_name)).all()
        return templates.TemplateResponse(request, "admin_users.html", {"request": request, "user": db_user, "active_role": "ADMIN", "all_users": all_users})

@app.get("/admin/matrix")
async def admin_matrix(request: Request):
    user_session = request.session.get('user')
    if not user_session: return RedirectResponse(url='/login')
    with Session(engine) as session:
        db_user = session.exec(select(User).where(User.ldap_uid == user_session['preferred_username'])).first()
        if not db_user or (request.session.get('active_role') or db_user.role.value) != 'ADMIN': return RedirectResponse(url='/')
        announcements = session.exec(select(Announcement).order_by(Announcement.created_at.desc()).limit(10)).all()
        return templates.TemplateResponse(request, "admin_matrix.html", {"request": request, "user": db_user, "active_role": "ADMIN", "announcements": announcements})

@app.get("/admin/ac-editor")
async def admin_ac_editor(request: Request):
    user_session = request.session.get('user')
    if not user_session: return RedirectResponse(url='/login')
    with Session(engine) as session:
        db_user = session.exec(select(User).where(User.ldap_uid == user_session['preferred_username'])).first()
        acs = session.exec(select(LearningOutcome).options(selectinload(LearningOutcome.competency)).order_by(LearningOutcome.code)).all()
        return templates.TemplateResponse(request, "ac_editor.html", {"request": request, "user": db_user, "active_role": "ADMIN", "learning_outcomes": acs})

@app.post("/admin/ac-editor-save")
async def admin_ac_save(request: Request):
    f = await request.form(); ac_id = int(f.get("ac_id"))
    with Session(engine) as session:
        ac = session.get(LearningOutcome, ac_id)
        if ac: ac.description = f.get("description"); session.add(ac); session.commit()
    return HTMLResponse(content="OK")

@app.get("/admin/activities")
async def admin_activities(request: Request):
    user_session = request.session.get('user')
    if not user_session: return RedirectResponse(url='/login')
    with Session(engine) as session:
        db_user = session.exec(select(User).where(User.ldap_uid == user_session['preferred_username'])).first()
        activities = session.exec(select(Activity).options(selectinload(Activity.responsible_user)).order_by(Activity.code)).all()
        return templates.TemplateResponse(request, "admin_activities.html", {"request": request, "user": db_user, "active_role": "ADMIN", "activities": activities})

@app.get("/admin/activities/{act_id}")
async def admin_activity_detail(request: Request, act_id: int):
    user_session = request.session.get('user')
    if not user_session: return RedirectResponse(url='/login')
    with Session(engine) as session:
        db_user = session.exec(select(User).where(User.ldap_uid == user_session['preferred_username'])).first()
        act = session.exec(select(Activity).options(selectinload(Activity.learning_outcomes).selectinload(LearningOutcome.resources), selectinload(Activity.activity_groups).selectinload(ActivityGroup.students), selectinload(Activity.activity_groups).selectinload(ActivityGroup.tutor)).where(Activity.id == act_id)).first()
        pedigree = [{"code": ac.code, "label": ac.label, "resources": [{"code": r.code, "label": r.label, "responsible": r.responsible} for r in ac.resources]} for ac in act.learning_outcomes]
        lt = sorted(list(set([r["responsible"] for p in pedigree for r in p["resources"] if r["responsible"] and r["responsible"] != "(inconnu)"])))
        teachers = session.exec(select(User).where(User.role != UserRole.STUDENT).order_by(User.full_name)).all()
        students = session.exec(select(User).join(Promotion).where(User.role == 'STUDENT', Promotion.entry_year == (2026 - act.level + 1))).all()
        return templates.TemplateResponse(request, "admin_activity_detail.html", {"request": request, "user": db_user, "active_role": "ADMIN", "activity": act, "pedigree": pedigree, "linked_teachers": lt, "teachers": teachers, "students": students})

@app.post("/admin/activities/{act_id}/responsible")
async def admin_activity_responsible(request: Request, act_id: int):
    f = await request.form(); resp_id = f.get("responsible_id")
    with Session(engine) as session:
        act = session.get(Activity, act_id)
        if act: act.responsible_id = int(resp_id) if resp_id else None; session.add(act); session.commit()
    return HTMLResponse(content="OK")

@app.post("/admin/activities/{act_id}/groups/add")
async def admin_activity_group_add(request: Request, act_id: int):
    with Session(engine) as session:
        c = session.exec(select(func.count(ActivityGroup.id)).where(ActivityGroup.activity_id == act_id)).one()
        session.add(ActivityGroup(name=f"Groupe {c + 1}", activity_id=act_id)); session.commit()
    return RedirectResponse(url=f"/admin/activities/{act_id}", status_code=303)

@app.post("/admin/groups/{group_id}/tutor")
async def admin_group_tutor(request: Request, group_id: int):
    f = await request.form(); tid = f.get("tutor_id")
    with Session(engine) as session:
        g = session.get(ActivityGroup, group_id)
        if g: g.tutor_id = int(tid) if tid else None; session.add(g); session.commit()
    return HTMLResponse(content="OK")

@app.post("/admin/groups/{group_id}/students/add")
async def admin_group_student_add(request: Request, group_id: int):
    f = await request.form(); uid = f.get("student_uid")
    if uid:
        with Session(engine) as session:
            ex = session.exec(select(ActivityGroupStudentLink).where(ActivityGroupStudentLink.group_id == group_id, ActivityGroupStudentLink.student_uid == uid)).first()
            if not ex: session.add(ActivityGroupStudentLink(group_id=group_id, student_uid=uid)); session.commit()
            g = session.get(ActivityGroup, group_id); return RedirectResponse(url=f"/admin/activities/{g.activity_id}", status_code=303)
    return RedirectResponse(url=request.headers.get("referer", "/"), status_code=303)

@app.delete("/admin/groups/{group_id}/students/{student_uid}")
async def admin_group_student_delete(request: Request, group_id: int, student_uid: str):
    with Session(engine) as session:
        l = session.exec(select(ActivityGroupStudentLink).where(ActivityGroupStudentLink.group_id == group_id, ActivityGroupStudentLink.student_uid == student_uid)).first()
        if l: session.delete(l); session.commit()
    return HTMLResponse(content="")

@app.get("/login")
async def login(request: Request): return await oauth.keycloak.authorize_redirect(request, f"https://hub.{settings.DOMAIN}/auth")

@app.get("/auth")
async def auth(request: Request):
    token = await oauth.keycloak.authorize_access_token(request); request.session['user'] = dict(token.get('userinfo'))
    return RedirectResponse(url='/')

@app.get("/logout")
async def logout(request: Request):
    request.session.clear(); return RedirectResponse(url=f"https://auth.{settings.DOMAIN}/realms/{settings.KEYCLOAK_REALM}/protocol/openid-connect/logout?client_id={settings.KEYCLOAK_CLIENT_ID}&post_logout_redirect_uri=https://hub.{settings.DOMAIN}/")

@app.get("/switch-role/{role}")
async def switch_role(request: Request, role: str): request.session['active_role'] = role; return RedirectResponse(url='/')
