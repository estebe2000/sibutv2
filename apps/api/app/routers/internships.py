from fastapi import APIRouter, HTTPException, Depends
from sqlmodel import Session, select
from typing import Optional
from datetime import datetime
from ..database import get_session
from ..models import User, Internship, UserRole
from ..dependencies import get_current_user

router = APIRouter()

@router.get("/{student_uid}")
async def get_internship(student_uid: str, session: Session = Depends(get_session)):
    """Récupère les infos de stage d'un étudiant"""
    statement = select(Internship).where(Internship.student_uid == student_uid)
    internship = session.exec(statement).first()
    if not internship:
        # Création automatique d'une entrée vide si inexistante
        internship = Internship(student_uid=student_uid)
        session.add(internship)
        session.commit()
        session.refresh(internship)
    return internship

@router.patch("/{student_uid}")
async def update_internship(student_uid: str, data: dict, session: Session = Depends(get_session), current_user: User = Depends(get_current_user)):
    """Met à jour les infos de stage (Dates pour tuteur, Infos pour étudiant)"""
    statement = select(Internship).where(Internship.student_uid == student_uid)
    internship = session.exec(statement).first()
    
    if not internship:
        raise HTTPException(status_code=404, detail="Stage non trouvé")

    # Logique de permissions simple
    is_staff = current_user.role in [UserRole.PROFESSOR, UserRole.ADMIN, UserRole.SUPER_ADMIN]
    is_owner = current_user.ldap_uid == student_uid

    for key, value in data.items():
        # Seul le staff peut modifier les dates
        if key in ["start_date", "end_date"] and not is_staff:
            continue
        # L'étudiant peut modifier ses infos d'entreprise
        if hasattr(internship, key):
            setattr(internship, key, value)

    session.add(internship)
    session.commit()
    session.refresh(internship)
    return internship
