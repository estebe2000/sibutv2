from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from starlette.middleware.sessions import SessionMiddleware
from uvicorn.middleware.proxy_headers import ProxyHeadersMiddleware
import os

from app.core.config import settings
from app.core.security import AuthRequiredException, auth_exception_handler, engine
from app.api.v1.api import api_router
from app.views import public, user, admin

app = FastAPI(title="Skills Hub Remaster")

# --- Middlewares ---
app.add_middleware(ProxyHeadersMiddleware, trusted_hosts="*")
app.add_middleware(
    SessionMiddleware, 
    secret_key=settings.SECRET_KEY, 
    session_cookie="skills_hub_session", 
    max_age=3600*24*7, 
    same_site="none", 
    https_only=True
)

# --- Exception Handlers ---
app.add_exception_handler(AuthRequiredException, auth_exception_handler)

# --- Statics ---
static_dir = os.path.join(os.path.dirname(__file__), "static")
app.mount("/static", StaticFiles(directory=static_dir), name="static")

# --- Database Startup ---
@app.on_event("startup")
def on_startup():
    from .models.models import SQLModel
    SQLModel.metadata.create_all(engine)

# --- Routes API ---
app.include_router(api_router, prefix="/api/v1")

# --- Routes Views ---
app.include_router(public.router)
app.include_router(user.router)
app.include_router(admin.router)
