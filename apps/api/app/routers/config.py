from fastapi import APIRouter, Depends
from sqlmodel import Session, select
from typing import List
from ..database import get_session
from ..models import SystemConfig
from ..dependencies import get_current_user

router = APIRouter(tags=["Config"])

@router.get("/config", response_model=List[SystemConfig])
def list_config(session: Session = Depends(get_session), current_user: str = Depends(get_current_user)):
    return session.exec(select(SystemConfig)).all()

@router.post("/config")
def update_config(config_data: List[dict], session: Session = Depends(get_session), current_user: str = Depends(get_current_user)):
    for item in config_data:
        existing = session.exec(select(SystemConfig).where(SystemConfig.key == item['key'])).first()
        if existing:
            existing.value = item['value']
            existing.category = item.get('category', existing.category)
            session.add(existing)
        else:
            session.add(SystemConfig(**item))
    session.commit()
    return {"status": "success"}

@router.get("/public/config")
def get_public_config(session: Session = Depends(get_session)):
    """
    Retourne la configuration publique pour le frontend et les services (PDF).
    Ne nécessite pas d'authentification.
    """
    keys = ["APP_LOGO_URL", "APP_PRIMARY_COLOR", "APP_WELCOME_MESSAGE"]
    config = {}
    for k in keys:
        item = session.exec(select(SystemConfig).where(SystemConfig.key == k)).first()
        if item:
            config[k] = item.value
    
    # Valeurs par défaut si non définies en base
    if "APP_PRIMARY_COLOR" not in config:
        config["APP_PRIMARY_COLOR"] = "#1971c2" # Mantine Blue 7 default
    if "APP_LOGO_URL" not in config:
        config["APP_LOGO_URL"] = "" 
        
    return config
