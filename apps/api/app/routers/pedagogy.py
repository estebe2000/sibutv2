from fastapi import APIRouter, HTTPException, Depends
from sqlmodel import Session, select
from typing import List
from ..database import get_session
from ..models import User, Group, PromotionResponsibility, UserRole
from ..dependencies import require_staff

router = APIRouter()

@router.get("/promotion-responsibilities")
async def list_responsibilities(session: Session = Depends(get_session)):
    return session.exec(select(PromotionResponsibility)).all()

@router.post("/assign-promotion")
async def assign_promotion(teacher_uid: str, group_id: int, session: Session = Depends(get_session)):
    """Assigne un enseignant comme responsable d'une promotion"""
    # Vérification
    teacher = session.exec(select(User).where(User.ldap_uid == teacher_uid)).first()
    if not teacher: raise HTTPException(status_code=404, detail="Enseignant non trouvé")
    
    group = session.get(Group, group_id)
    if not group: raise HTTPException(status_code=404, detail="Groupe non trouvé")

    # Vérifier doublon
    existing = session.exec(select(PromotionResponsibility).where(
        PromotionResponsibility.teacher_uid == teacher_uid,
        PromotionResponsibility.group_id == group_id
    )).first()
    
    if not existing:
        res = PromotionResponsibility(teacher_uid=teacher_uid, group_id=group_id)
        session.add(res)
        session.commit()
    
    return {"status": "success"}

@router.delete("/unassign-promotion")
async def unassign_promotion(teacher_uid: str, group_id: int, session: Session = Depends(get_session)):
    statement = select(PromotionResponsibility).where(
        PromotionResponsibility.teacher_uid == teacher_uid,
        PromotionResponsibility.group_id == group_id
    )
    res = session.exec(statement).first()
    if res:
        session.delete(res)
        session.commit()
    return {"status": "success"}

@router.get("/teacher/{teacher_uid}/promotions")
async def get_teacher_promotions(teacher_uid: str, session: Session = Depends(get_session)):
    """Liste les IDs de groupes dont l'enseignant est responsable"""
    statement = select(PromotionResponsibility.group_id).where(PromotionResponsibility.teacher_uid == teacher_uid)
    return session.exec(statement).all()
