from fastapi import FastAPI, Request, Depends, HTTPException
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from starlette.middleware.sessions import SessionMiddleware
from authlib.integrations.starlette_client import OAuth
from sqlmodel import Session, select, create_engine, func
from uvicorn.middleware.proxy_headers import ProxyHeadersMiddleware
from .core.config import settings
from .models.models import User, UserRole, Activity, Competency
import os

app = FastAPI(title="Skills Hub Remaster")

# --- CONFIANCE PROXY ---
# On dit à FastAPI de faire confiance aux en-têtes X-Forwarded-* (indispensable pour Cloudflare)
app.add_middleware(ProxyHeadersMiddleware, trusted_hosts="*")

# --- PROTECTION SESSION ---
app.add_middleware(
    SessionMiddleware, 
    secret_key="skills-hub-secret-key-2026",
    session_cookie="skills_hub_session",
    same_site="lax",
    https_only=False # On laisse à False car Nginx/Cloudflare gèrent la terminaison SSL
)

engine = create_engine(settings.DATABASE_URL)

@app.on_event("startup")
def on_startup():
    from .models.models import SQLModel
    SQLModel.metadata.create_all(engine)

# Configuration OIDC
DOMAIN = os.getenv("DOMAIN", "educ-ai.fr")
REALM = os.getenv("KEYCLOAK_REALM", "but-tc")
KC_INTERNAL = os.getenv("KEYCLOAK_INTERNAL_URL", "http://keycloak:8080")
KC_EXTERNAL_BASE = f"https://auth.{DOMAIN}/realms/{REALM}"

oauth = OAuth()
oauth.register(
    name='keycloak',
    client_id=os.getenv("KEYCLOAK_CLIENT_ID"),
    client_secret=os.getenv("KEYCLOAK_CLIENT_SECRET"),
    authorize_url=f"{KC_EXTERNAL_BASE}/protocol/openid-connect/auth",
    access_token_url=f"{KC_INTERNAL}/realms/{REALM}/protocol/openid-connect/token",
    userinfo_endpoint=f"{KC_INTERNAL}/realms/{REALM}/protocol/openid-connect/userinfo",
    jwks_uri=f"{KC_INTERNAL}/realms/{REALM}/protocol/openid-connect/certs",
    client_kwargs={'scope': 'openid profile email'},
)

app.mount("/static", StaticFiles(directory="app/static"), name="static")
templates = Jinja2Templates(directory="app/templates")

from .services.matrix_service import get_room_messages

@app.get("/", response_class=HTMLResponse)
async def dashboard(request: Request):
    user_session = request.session.get('user')
    if not user_session:
        return RedirectResponse(url='/login')
    
    with Session(engine) as session:
        db_user = session.exec(select(User).where(User.ldap_uid == user_session['preferred_username'])).first()
        if not db_user:
            return RedirectResponse(url='/login')

        # news_feed = await get_room_messages("general")
        news_feed = [] # Temporairement désactivé pour éviter le 504
        return templates.TemplateResponse(
            request=request, 
            name="dashboard.html", 
            context={"user": db_user, "stats": {}, "data": {}, "news": news_feed}
        )

@app.get("/login")
async def login(request: Request):
    # On utilise l'URL absolue HTTPS pour le callback
    redirect_uri = f"https://hub.{DOMAIN}/auth"
    request.session.clear()
    return await oauth.keycloak.authorize_redirect(request, redirect_uri)

@app.get("/auth")
async def auth_callback(request: Request):
    try:
        # L'échange de token se fait en interne (backend -> keycloak)
        token = await oauth.keycloak.authorize_access_token(request)
        user_info = token.get('userinfo')
        request.session['user'] = dict(user_info)
        return RedirectResponse(url='/')
    except Exception as e:
        print(f"Auth Error: {e}")
        return RedirectResponse(url='/login')

@app.get("/logout")
async def logout(request: Request):
    request.session.clear()
    logout_url = f"https://auth.{DOMAIN}/realms/{REALM}/protocol/openid-connect/logout?client_id={os.getenv('KEYCLOAK_CLIENT_ID')}&post_logout_redirect_uri=https://hub.{DOMAIN}/"
    return RedirectResponse(url=logout_url)
