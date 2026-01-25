from fastapi import APIRouter, HTTPException, Depends
from sqlmodel import Session, select
from typing import List, Optional
from ..database import get_session
from ..models import User, Group, PromotionResponsibility, UserRole, ResponsibilityMatrix, ResponsibilityType, Resource, Activity
from ..dependencies import require_staff
import csv
import io
import json
from fastapi.responses import StreamingResponse

router = APIRouter()

async def get_enriched_matrix(session: Session):
    """Fonction helper pour enrichir la matrice avec les labels réels"""
    matrix = session.exec(select(ResponsibilityMatrix)).all()
    report = []
    for entry in matrix:
        user = session.exec(select(User).where(User.ldap_uid == entry.user_id)).first()
        
        entity_label = entry.entity_id
        e_type = entry.entity_type.value if hasattr(entry.entity_type, 'value') else str(entry.entity_type)
        
        if e_type == "RESOURCE":
            res = session.exec(select(Resource).where(Resource.code == entry.entity_id)).first()
            if res: entity_label = f"{res.code} : {res.label}"
        elif e_type == "ACTIVITY":
            if entry.entity_id.isdigit():
                act = session.get(Activity, int(entry.entity_id))
                if act: entity_label = f"{act.code} : {act.label}"
        elif e_type == "STUDENT":
            student = session.exec(select(User).where(User.ldap_uid == entry.entity_id)).first()
            if student: entity_label = student.full_name

        report.append({
            "type": e_type,
            "id": entry.entity_id,
            "label": entity_label,
            "role": entry.role_type.value if hasattr(entry.role_type, 'value') else str(entry.role_type),
            "name": user.full_name if user else entry.user_id,
            "email": user.email if user else "N/A"
        })
    return report

@router.get("/governance-report")
async def get_governance_report(session: Session = Depends(get_session)):
    """Retourne la liste complète des responsabilités avec détails utilisateurs et libellés réels"""
    data = await get_enriched_matrix(session)
    # On remap pour la compatibilité frontend actuelle
    return [{
        "entity_type": d["type"],
        "entity_id": d["id"],
        "entity_label": d["label"],
        "role": d["role"],
        "user_name": d["name"],
        "user_email": d["email"]
    } for d in data]

@router.get("/governance-report/export/json")
async def export_gov_json(type: Optional[str] = None, session: Session = Depends(get_session)):
    data = await get_enriched_matrix(session)
    if type:
        data = [d for d in data if d["type"] == type]
    return data

@router.get("/governance-report/export/csv")
async def export_gov_csv(type: Optional[str] = None, session: Session = Depends(get_session)):
    data = await get_enriched_matrix(session)
    if type:
        data = [d for d in data if d["type"] == type]
    
    output = io.StringIO()
    # Excel compatibility
    output.write('\ufeff')
    writer = csv.DictWriter(output, fieldnames=["type", "id", "label", "role", "name", "email"], delimiter=';')
    writer.writeheader()
    writer.writerows(data)
    
    filename = f"export_gouvernance_{type.lower() if type else 'global'}.csv"
    return StreamingResponse(
        io.BytesIO(output.getvalue().encode('utf-8-sig')),
        media_type="text/csv",
        headers={"Content-Disposition": f"attachment; filename={filename}"}
    )

@router.get("/governance-report/pdf")
async def export_governance_report_pdf(type: Optional[str] = None, session: Session = Depends(get_session)):
    """Exporte le rapport de gouvernance en PDF"""
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
    teacher = session.exec(select(User).where(User.ldap_uid == teacher_uid)).first()
    if not teacher: raise HTTPException(status_code=404, detail="Enseignant non trouvé")
    group = session.get(Group, group_id)
    if not group: raise HTTPException(status_code=404, detail="Groupe non trouvé")
    existing = session.exec(select(PromotionResponsibility).where(PromotionResponsibility.teacher_uid == teacher_uid, PromotionResponsibility.group_id == group_id)).first()
    if not existing:
        res = PromotionResponsibility(teacher_uid=teacher_uid, group_id=group_id)
        session.add(res); session.commit()
    return {"status": "success"}

@router.delete("/unassign-promotion")
async def unassign_promotion(teacher_uid: str, group_id: int, session: Session = Depends(get_session)):
    statement = select(PromotionResponsibility).where(PromotionResponsibility.teacher_uid == teacher_uid, PromotionResponsibility.group_id == group_id)
    res = session.exec(statement).first()
    if res: session.delete(res); session.commit()
    return {"status": "success"}

@router.get("/teacher/{teacher_uid}/promotions")
async def get_teacher_promotions(teacher_uid: str, session: Session = Depends(get_session)):
    statement = select(PromotionResponsibility.group_id).where(PromotionResponsibility.teacher_uid == teacher_uid)
    return session.exec(statement).all()
