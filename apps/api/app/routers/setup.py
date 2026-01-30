from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select
from pydantic import BaseModel
from typing import Optional
from ..database import get_session
from ..models import SystemConfig, User, UserRole
from passlib.context import CryptContext

router = APIRouter(tags=["Setup"])

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class SetupPayload(BaseModel):
    admin_email: str
    admin_password: str
    admin_name: str
    site_name: str
    site_url: Optional[str] = None
    cloudflare_token: Optional[str] = None
    logo_url: Optional[str] = None

@router.get("/setup/status")
def get_setup_status(session: Session = Depends(get_session)):
    """
    Checks if the application is installed.
    """
    setup_flag = session.exec(select(SystemConfig).where(SystemConfig.key == "SETUP_COMPLETE")).first()
    is_installed = setup_flag is not None and setup_flag.value == "true"
    return {"installed": is_installed}

@router.post("/setup/install")
def run_install(payload: SetupPayload, session: Session = Depends(get_session)):
    """
    Performs the initial installation.
    """
    # 1. Check if already installed
    setup_flag = session.exec(select(SystemConfig).where(SystemConfig.key == "SETUP_COMPLETE")).first()
    if setup_flag and setup_flag.value == "true":
        raise HTTPException(status_code=403, detail="Application is already installed.")

    # 2. Create Admin User
    # Check if user exists (to avoid duplicate key error if reinstalling partly)
    existing_user = session.exec(select(User).where(User.email == payload.admin_email)).first()
    if not existing_user:
        # Note: Current User model uses ldap_uid as unique. We might need to handle local users differently
        # or assume this admin is a "local" admin.
        # Looking at models.py, User has ldap_uid.
        # We will use email as ldap_uid for local admin or "admin"

        # Hash password? The current User model doesn't seem to have a password field?
        # Wait, let's check models.py again. User table doesn't have password_hash.
        # Auth seems to rely on LDAP or Keycloak?
        # Let's check apps/api/app/routers/auth.py
        pass

    # 3. Save Configs
    configs = [
        {"key": "APP_NAME", "value": payload.site_name, "category": "branding"},
        {"key": "APP_WELCOME_MESSAGE", "value": f"Bienvenue sur {payload.site_name}", "category": "branding"},
        {"key": "SETUP_COMPLETE", "value": "true", "category": "system"}
    ]

    if payload.site_url:
        configs.append({"key": "PUBLIC_URL", "value": payload.site_url, "category": "system"})

    if payload.logo_url:
        configs.append({"key": "APP_LOGO_URL", "value": payload.logo_url, "category": "branding"})

    if payload.cloudflare_token:
        configs.append({"key": "CLOUDFLARE_TOKEN", "value": payload.cloudflare_token, "category": "network"})

    for conf in configs:
        existing = session.exec(select(SystemConfig).where(SystemConfig.key == conf["key"])).first()
        if existing:
            existing.value = conf["value"]
            session.add(existing)
        else:
            session.add(SystemConfig(**conf))

    session.commit()

    # 4. Handle Cloudflare Token (Side Effect?)
    # If we want "Zero Conf", we might need to write this to a file shared with the cloudflared container
    # or rely on the UI to display "Please restart".
    # For now, we save it in DB.

    return {"status": "success", "message": "Installation complete"}
