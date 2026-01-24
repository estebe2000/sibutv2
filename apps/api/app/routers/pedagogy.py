from fastapi import APIRouter, HTTPException, Depends
from sqlmodel import Session, select
from typing import List, Optional
from ..database import get_session
from ..models import User, Group, PromotionResponsibility, UserRole, ResponsibilityMatrix, ResponsibilityType
from ..dependencies import require_staff

router = APIRouter()

@router.get("/governance-report")
async def get_governance_report(session: Session = Depends(get_session)):
    """Retourne la liste complète des responsabilités avec détails utilisateurs"""
    matrix = session.exec(select(ResponsibilityMatrix)).all()
    report = []
    for entry in matrix:
        user = session.exec(select(User).where(User.ldap_uid == entry.user_id)).first()
        report.append({
            "entity_type": entry.entity_type,
            "entity_id": entry.entity_id,
            "role": entry.role_type,
            "user_name": user.full_name if user else entry.user_id,
            "user_email": user.email if user else "N/A"
        })
    return report

@router.get("/governance-report/pdf")
async def export_governance_report_pdf(type: Optional[str] = None, session: Session = Depends(get_session)):
    """Exporte le rapport de gouvernance en PDF, optionnellement filtré par type"""
    from fastapi.responses import StreamingResponse
    from ..services.pdf_service import generate_governance_report_pdf
    
    pdf_buffer = generate_governance_report_pdf(session, filter_type=type)
    filename = f"rapport_gouvernance_{type.lower() if type else 'global'}.pdf"
    return StreamingResponse(
        pdf_buffer, 
        media_type="application/pdf",
        headers={"Content-Disposition": f"attachment; filename={filename}"}
    )

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
