from fastapi import FastAPI, Request, Depends, HTTPException
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from starlette.middleware.sessions import SessionMiddleware
from authlib.integrations.starlette_client import OAuth
from sqlmodel import Session, select, create_engine, func
from uvicorn.middleware.proxy_headers import ProxyHeadersMiddleware
from .core.config import settings
from .models.models import User, UserRole, Activity, Competency, Promotion, Group, Resource, Announcement
from .services.matrix_service import matrix_service
import os
import httpx
import json
import asyncio

app = FastAPI(title="Skills Hub Remaster")

# --- CONFIANCE PROXY ---
app.add_middleware(ProxyHeadersMiddleware, trusted_hosts="*")

# --- PROTECTION SESSION ---
app.add_middleware(
    SessionMiddleware, 
    secret_key=settings.SECRET_KEY,
    session_cookie="skills_hub_session",
    same_site="lax",
    https_only=False
)

engine = create_engine(settings.DATABASE_URL)
templates = Jinja2Templates(directory="app/templates")

@app.on_event("startup")
def on_startup():
    from .models.models import SQLModel
    SQLModel.metadata.create_all(engine)

# Configuration OIDC
oauth = OAuth()
oauth.register(
    name='keycloak',
    client_id=settings.KEYCLOAK_CLIENT_ID,
    client_secret=settings.KEYCLOAK_CLIENT_SECRET,
    authorize_url=f"https://auth.{settings.DOMAIN}/realms/{settings.KEYCLOAK_REALM}/protocol/openid-connect/auth",
    access_token_url=f"http://keycloak:8080/realms/{settings.KEYCLOAK_REALM}/protocol/openid-connect/token",
    userinfo_endpoint=f"http://keycloak:8080/realms/{settings.KEYCLOAK_REALM}/protocol/openid-connect/userinfo",
    jwks_uri=f"http://keycloak:8080/realms/{settings.KEYCLOAK_REALM}/protocol/openid-connect/certs",
    client_kwargs={'scope': 'openid profile email'},
)

from app.api.v1.api import api_router
app.include_router(api_router, prefix="/api/v1")

@app.get("/", response_class=HTMLResponse)
async def dashboard(request: Request):
    user_session = request.session.get('user')
    if not user_session: return RedirectResponse(url='/login')
    with Session(engine) as session:
        db_user = session.exec(select(User).where(User.ldap_uid == user_session['preferred_username'])).first()
        if not db_user: return RedirectResponse(url='/login')
        active_role = request.session.get('active_role') or db_user.role.value
        stats = {}
        data = {}
        if active_role == 'ADMIN':
            stats = {
                "user_count": session.exec(select(func.count(User.id))).one(),
                "comp_count": session.exec(select(func.count(Competency.id))).one(),
                "sae_count": session.exec(select(func.count(Activity.id))).one(),
            }
            data["recent_activities"] = session.exec(select(Activity).limit(5)).all()
        elif active_role == 'PROFESSOR':
            data["my_resources"] = session.exec(select(Resource).where(Resource.responsible_uid == db_user.ldap_uid)).all()
            data["my_saes"] = session.exec(select(Activity).where(Activity.type == "SAE").limit(3)).all()
        elif active_role == 'STUDENT':
            data["competencies"] = session.exec(select(Competency).limit(3)).all()
        
        # Récupération des annonces depuis la base locale (Fiabilité garantie)
        ann_list = session.exec(select(Announcement).order_by(Announcement.created_at.desc()).limit(5)).all()
        news = []
        for a in ann_list:
            news.append({
                "sender": a.author_uid,
                "content": f"**{a.title}**<br>{a.content}",
                "timestamp": a.created_at
            })
            
        return templates.TemplateResponse(request, "dashboard.html", {
            "user": db_user, "active_role": active_role, "stats": stats, "data": data, "news": news
        })

@app.get("/switch-role/{role}")
async def switch_role(request: Request, role: str):
    user_session = request.session.get('user')
    if not user_session: return RedirectResponse(url='/login')
    with Session(engine) as session:
        db_user = session.exec(select(User).where(User.ldap_uid == user_session['preferred_username'])).first()
        if db_user and any(r.value == role for r in db_user.roles_list):
            request.session['active_role'] = role
    return RedirectResponse(url='/')

@app.get("/login")
async def login(request: Request):
    redirect_uri = f"https://hub.{settings.DOMAIN}/auth"
    request.session.clear()
    return await oauth.keycloak.authorize_redirect(request, redirect_uri)

@app.get("/auth")
async def auth_callback(request: Request):
    try:
        token = await oauth.keycloak.authorize_access_token(request)
        user_info = token.get('userinfo')
        request.session['user'] = dict(user_info)
        return RedirectResponse(url='/')
    except:
        return RedirectResponse(url='/login')

@app.get("/effectifs")
async def effectifs(request: Request):
    user_session = request.session.get('user')
    if not user_session: return RedirectResponse(url='/login')
    with Session(engine) as session:
        db_user = session.exec(select(User).where(User.ldap_uid == user_session['preferred_username'])).first()
        if not db_user: return RedirectResponse(url='/login')
        active_role = request.session.get('active_role') or db_user.role.value
        if active_role != 'ADMIN': return RedirectResponse(url='/')
        from sqlalchemy.orm import selectinload
        statement = select(Promotion).options(selectinload(Promotion.users), selectinload(Promotion.groups))
        promotions = session.exec(statement).all()
        total_count = sum(len(p.users) for p in promotions)
        current_year = 2026
        promos_by_level = {
            1: next((p for p in promotions if p.entry_year == current_year), None),
            2: next((p for p in promotions if p.entry_year == current_year - 1), None),
            3: next((p for p in promotions if p.entry_year == current_year - 2), None),
        }
        resources = session.exec(select(Resource).order_by(Resource.code)).all()
        teachers = session.exec(select(User).where(User.role != UserRole.STUDENT).order_by(User.full_name)).all()
        return templates.TemplateResponse(request, "effectifs.html", {
            "user": db_user, "active_role": active_role, "promos_by_level": promos_by_level,
            "total_users": total_count, "resources": resources, "teachers": teachers
        })

@app.get("/api/teacher/{ldap_uid}")
async def get_teacher_details(ldap_uid: str):
    with Session(engine) as session:
        teacher = session.exec(select(User).where(User.ldap_uid == ldap_uid)).first()
        if not teacher: return {"error": "Enseignant non trouvé"}
        resources = session.exec(select(Resource).where(Resource.responsible_uid == teacher.ldap_uid)).all()
        if not resources:
            resources = session.exec(select(Resource).where(Resource.responsible == teacher.full_name)).all()
        return {
            "ldap_uid": teacher.ldap_uid, "full_name": teacher.full_name, "email": teacher.email,
            "phone": teacher.phone, "roles": teacher.roles_list,
            "resources": [{"code": r.code, "label": r.label} for r in resources]
        }

@app.get("/synchro-scodoc")
async def synchro_scodoc(request: Request):
    user_session = request.session.get('user')
    if not user_session: return RedirectResponse(url='/login')
    with Session(engine) as session:
        db_user = session.exec(select(User).where(User.ldap_uid == user_session['preferred_username'])).first()
        if not db_user: return RedirectResponse(url='/login')
        active_role = request.session.get('active_role') or db_user.role.value
        if active_role != 'ADMIN': return RedirectResponse(url='/')
        scodoc_data = {"hierarchy": {}, "resources": []}
        try:
            async with httpx.AsyncClient(timeout=5.0) as client:
                h_resp = await client.get("http://host.docker.internal:8092/api/hierarchie")
                r_resp = await client.get("http://host.docker.internal:8092/api/ressources")
                if h_resp.status_code == 200: scodoc_data["hierarchy"] = h_resp.json() or {}
                if r_resp.status_code == 200: scodoc_data["resources"] = r_resp.json() or []
        except: pass
        return templates.TemplateResponse(request, "dispatch_students.html", {
            "user": db_user, "active_role": active_role, "scodoc": scodoc_data
        })

@app.get("/admin/users")
async def admin_users(request: Request):
    user_session = request.session.get('user')
    if not user_session: return RedirectResponse(url='/login')
    with Session(engine) as session:
        db_user = session.exec(select(User).where(User.ldap_uid == user_session['preferred_username'])).first()
        if not db_user: return RedirectResponse(url='/login')
        active_role = request.session.get('active_role') or db_user.role.value
        if active_role != 'ADMIN': return RedirectResponse(url='/')
        all_users = session.exec(select(User).where(User.role != UserRole.STUDENT).order_by(User.full_name)).all()
        return templates.TemplateResponse(request, "admin_users.html", {
            "user": db_user, "active_role": active_role, "all_users": all_users
        })

@app.get("/admin/matrix")
async def admin_matrix(request: Request):
    user_session = request.session.get('user')
    if not user_session: return RedirectResponse(url='/login')
    with Session(engine) as session:
        db_user = session.exec(select(User).where(User.ldap_uid == user_session['preferred_username'])).first()
        if not db_user: return RedirectResponse(url='/login')
        active_role = request.session.get('active_role') or db_user.role.value
        if active_role != 'ADMIN': return RedirectResponse(url='/')
        announcements = session.exec(select(Announcement).order_by(Announcement.created_at.desc()).limit(10)).all()
        return templates.TemplateResponse(request, "admin_matrix.html", {
            "user": db_user, "active_role": active_role, "announcements": announcements
        })

@app.post("/api/v1/admin/matrix/announce")
async def matrix_announce(data: dict, request: Request):
    user_session = request.session.get('user')
    if not user_session: raise HTTPException(status_code=401)
    room_id, event_id = await matrix_service.broadcast_announcement(
        title=data.get("title"), content=data.get("content"),
        room_type=data.get("room"), priority=data.get("priority")
    )
    if event_id:
        with Session(engine) as session:
            ann = Announcement(
                matrix_event_id=event_id, matrix_room_id=room_id,
                title=data.get("title"), content=data.get("content"),
                author_uid=user_session['preferred_username']
            )
            session.add(ann); session.commit()
        return {"status": "success"}
    raise HTTPException(status_code=500)

@app.delete("/api/v1/admin/matrix/announcements/{ann_id}")
async def delete_announcement(ann_id: int, request: Request):
    user_session = request.session.get('user')
    if not user_session: raise HTTPException(status_code=401)
    with Session(engine) as session:
        ann = session.get(Announcement, ann_id)
        if not ann: raise HTTPException(status_code=404)
        await matrix_service.redact_event(ann.matrix_room_id, ann.matrix_event_id)
        session.delete(ann); session.commit()
    return {"status": "success"}

@app.post("/api/v1/admin/matrix/sync-rooms")
async def sync_matrix_rooms(request: Request):
    user_session = request.session.get('user')
    if not user_session: raise HTTPException(status_code=401)
    created_count = 0
    with Session(engine) as session:
        promos = session.exec(select(Promotion).where(Promotion.matrix_room_id == None)).all()
        for p in promos:
            room_id = await matrix_service.create_room(name=f"PROMO {p.name}")
            if room_id:
                p.matrix_room_id = room_id
                session.add(p); created_count += 1
            await asyncio.sleep(2)
        groups = session.exec(select(Group).where(Group.matrix_room_id == None)).all()
        for g in groups:
            room_id = await matrix_service.create_room(name=f"GROUPE {g.name}")
            if room_id:
                g.matrix_room_id = room_id
                session.add(g); created_count += 1
            await asyncio.sleep(2)
        session.commit()
    return {"status": "success", "created": created_count}

@app.get("/logout")
async def logout(request: Request):
    request.session.clear()
    logout_url = f"https://auth.{settings.DOMAIN}/realms/{settings.KEYCLOAK_REALM}/protocol/openid-connect/logout?client_id={settings.KEYCLOAK_CLIENT_ID}&post_logout_redirect_uri=https://hub.{settings.DOMAIN}/"
    return RedirectResponse(url=logout_url)
