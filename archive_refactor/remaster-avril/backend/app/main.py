from fastapi import FastAPI, Request, Depends, HTTPException
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from starlette.middleware.sessions import SessionMiddleware
from authlib.integrations.starlette_client import OAuth
from sqlmodel import Session, select, create_engine, func
from uvicorn.middleware.proxy_headers import ProxyHeadersMiddleware
from .core.config import settings
from .models.models import User, UserRole, Activity, Competency, Promotion, Group, Resource
import os
import httpx
import json

app = FastAPI(title="Skills Hub Remaster")

# --- CONFIANCE PROXY ---
app.add_middleware(ProxyHeadersMiddleware, trusted_hosts="*")

# --- PROTECTION SESSION ---
app.add_middleware(
    SessionMiddleware, 
    secret_key="skills-hub-secret-key-2026",
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
DOMAIN = os.getenv("DOMAIN", "educ-ai.fr")
REALM = os.getenv("KEYCLOAK_REALM", "but-tc")

oauth = OAuth()
oauth.register(
    name='keycloak',
    client_id=os.getenv("KEYCLOAK_CLIENT_ID"),
    client_secret=os.getenv("KEYCLOAK_CLIENT_SECRET"),
    authorize_url=f"https://auth.{DOMAIN}/realms/{REALM}/protocol/openid-connect/auth",
    access_token_url=f"http://keycloak:8080/realms/{REALM}/protocol/openid-connect/token",
    userinfo_endpoint=f"http://keycloak:8080/realms/{REALM}/protocol/openid-connect/userinfo",
    jwks_uri=f"http://keycloak:8080/realms/{REALM}/protocol/openid-connect/certs",
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
        return templates.TemplateResponse(request, "dashboard.html", {"user": db_user, "stats": {}, "data": {}, "news": []})

@app.get("/login")
async def login(request: Request):
    redirect_uri = f"https://hub.{DOMAIN}/auth"
    request.session.clear()
    return await oauth.keycloak.authorize_redirect(request, redirect_uri)

@app.get("/auth")
async def auth_callback(request: Request):
    try:
        token = await oauth.keycloak.authorize_access_token(request)
        user_info = token.get('userinfo')
        request.session['user'] = dict(user_info)
        return RedirectResponse(url='/')
    except Exception as e:
        return RedirectResponse(url='/login')

@app.get("/effectifs")
async def effectifs(request: Request):
    user_session = request.session.get('user')
    if not user_session: return RedirectResponse(url='/login')
    with Session(engine) as session:
        db_user = session.exec(select(User).where(User.ldap_uid == user_session['preferred_username'])).first()
        if not db_user: return RedirectResponse(url='/login')
        promotions = session.exec(select(Promotion)).all()
        resources = session.exec(select(Resource)).all()
        return templates.TemplateResponse(request, "effectifs.html", {"user": db_user, "promotions": promotions, "resources": resources})

@app.get("/synchro-scodoc")
async def synchro_scodoc(request: Request):
    user_session = request.session.get('user')
    if not user_session: return RedirectResponse(url='/login')
    with Session(engine) as session:
        db_user = session.exec(select(User).where(User.ldap_uid == user_session['preferred_username'])).first()
        if not db_user: return RedirectResponse(url='/login')
        scodoc_data = {"hierarchy": {}, "resources": []}
        try:
            async with httpx.AsyncClient(timeout=5.0) as client:
                h_resp = await client.get("http://host.docker.internal:8092/api/hierarchie")
                r_resp = await client.get("http://host.docker.internal:8092/api/ressources")
                if h_resp.status_code == 200: scodoc_data["hierarchy"] = h_resp.json() or {}
                if r_resp.status_code == 200: scodoc_data["resources"] = r_resp.json() or []
        except: pass
        return templates.TemplateResponse(request, "dispatch_students.html", {"user": db_user, "scodoc": scodoc_data})

@app.get("/winston/audit")
async def winston_audit(request: Request):
    with Session(engine) as session:
        db_user = session.exec(select(User).where(User.role == UserRole.ADMIN)).first()
        promotions = session.exec(select(Promotion)).all()
        resources = session.exec(select(Resource)).all()
        eff_html = templates.TemplateResponse(request, "effectifs.html", {"user": db_user, "promotions": promotions, "resources": resources}).body.decode()
        return {"status": "ok", "has_but1": "BUT 1" in eff_html, "has_but2": "BUT 2" in eff_html, "has_but3": "BUT 3" in eff_html}

@app.get("/admin/users")
async def admin_users(request: Request):
    user_session = request.session.get('user')
    if not user_session: return RedirectResponse(url='/login')
    with Session(engine) as session:
        db_user = session.exec(select(User).where(User.ldap_uid == user_session['preferred_username'])).first()
        if not db_user or db_user.role != UserRole.ADMIN:
            return RedirectResponse(url='/')
        
        # On ne récupère que les profs et admins (on exclut les étudiants de cette vue)
        all_users = session.exec(
            select(User).where(User.role != UserRole.STUDENT).order_by(User.full_name)
        ).all()
        return templates.TemplateResponse(request, "admin_users.html", {"user": db_user, "all_users": all_users})
async def logout(request: Request):
    request.session.clear()
    logout_url = f"https://auth.{DOMAIN}/realms/{REALM}/protocol/openid-connect/logout?client_id={os.getenv('KEYCLOAK_CLIENT_ID')}&post_logout_redirect_uri=https://hub.{DOMAIN}/"
    return RedirectResponse(url=logout_url)
