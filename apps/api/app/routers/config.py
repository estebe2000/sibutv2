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
