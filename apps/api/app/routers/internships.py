import uuid
from fastapi import APIRouter, HTTPException, Depends
from sqlmodel import Session, select
from typing import Optional, List
from datetime import datetime, timedelta
from ..database import get_session
from ..models import User, Internship, UserRole, InternshipVisit, InternshipEvaluation
from ..dependencies import get_current_user

router = APIRouter()

@router.get("/{student_uid}")
async def get_active_internship(student_uid: str, session: Session = Depends(get_session)):
    """Récupère le stage ACTIF d'un étudiant ou en crée un si aucun n'existe"""
    statement = select(Internship).where(Internship.student_uid == student_uid, Internship.is_active == True)
    internship = session.exec(statement).first()
    
    if not internship:
        # Création automatique du premier stage actif si inexistant
        internship = Internship(student_uid=student_uid, is_active=True)
        session.add(internship)
        session.commit()
        session.refresh(internship)
    return internship

@router.get("/{student_uid}/history", response_model=List[Internship])
async def get_internship_history(student_uid: str, session: Session = Depends(get_session)):
    """Récupère tous les stages (actifs et archivés) d'un étudiant"""
    statement = select(Internship).where(Internship.student_uid == student_uid).order_by(Internship.id.desc())
    return session.exec(statement).all()

@router.post("/{student_uid}/new")
async def create_new_internship(student_uid: str, session: Session = Depends(get_session), current_user: User = Depends(get_current_user)):
    """Archive les stages actuels et en crée un nouveau"""
    if current_user.role not in [UserRole.PROFESSOR, UserRole.ADMIN, UserRole.SUPER_ADMIN, UserRole.STUDY_DIRECTOR, UserRole.DEPT_HEAD]:
        raise HTTPException(status_code=403, detail="Non autorisé")

    # 1. Archiver tous les stages actuels
    statement = select(Internship).where(Internship.student_uid == student_uid, Internship.is_active == True)
    active_internships = session.exec(statement).all()
    for i in active_internships:
        i.is_active = False
        session.add(i)
    
    # 2. Créer le nouveau stage
    new_internship = Internship(student_uid=student_uid, is_active=True)
    session.add(new_internship)
    session.commit()
    session.refresh(new_internship)
    return new_internship

@router.delete("/{internship_id}")
async def delete_internship(internship_id: int, session: Session = Depends(get_session), current_user: User = Depends(get_current_user)):
    """Supprime définitivement un stage (Autorisé pour tout le Staff)"""
    if current_user.role not in [UserRole.PROFESSOR, UserRole.STUDY_DIRECTOR, UserRole.ADMIN, UserRole.SUPER_ADMIN, UserRole.DEPT_HEAD]:
        raise HTTPException(status_code=403, detail="Non autorisé à supprimer un stage")

    internship = session.get(Internship, internship_id)
    if not internship:
        raise HTTPException(status_code=404, detail="Stage non trouvé")

    # Supprimer les visites liées
    statement_v = select(InternshipVisit).where(InternshipVisit.internship_id == internship_id)
    visits = session.exec(statement_v).all()
    for v in visits:
        session.delete(v)

    # Supprimer les évaluations liées
    statement_e = select(InternshipEvaluation).where(InternshipEvaluation.internship_id == internship_id)
    evals = session.exec(statement_e).all()
    for e in evals:
        session.delete(e)

    # On force le flush pour s'assurer que les suppressions sont prises en compte par les contraintes FK
    session.flush()
    
    session.delete(internship)
    session.commit()
    return {"status": "success", "message": "Stage supprimé"}

@router.patch("/{student_uid}")
async def update_internship(student_uid: str, data: dict, session: Session = Depends(get_session), current_user: User = Depends(get_current_user)):
    """Met à jour le stage ACTIF"""
    statement = select(Internship).where(Internship.student_uid == student_uid, Internship.is_active == True)
    internship = session.exec(statement).first()
    
    if not internship:
        raise HTTPException(status_code=404, detail="Stage actif non trouvé")

    is_staff = current_user.role in [UserRole.PROFESSOR, UserRole.ADMIN, UserRole.SUPER_ADMIN, UserRole.STUDY_DIRECTOR, UserRole.DEPT_HEAD]
    
    for key, value in data.items():
        if key in ["start_date", "end_date"] and not is_staff: continue
        if hasattr(internship, key):
            setattr(internship, key, value)

    session.add(internship)
    session.commit()
    session.refresh(internship)
    return internship

# ... (les autres endpoints GET visits, POST evaluate, etc. doivent aussi pointer sur le stage ACTIF)
# Je vais les adapter pour qu'ils utilisent l'ID ou cherchent toujours l'actif par défaut

@router.get("/{student_uid}/visits", response_model=List[InternshipVisit])
async def get_internship_visits(student_uid: str, session: Session = Depends(get_session)):
    statement = select(Internship).where(Internship.student_uid == student_uid, Internship.is_active == True)
    internship = session.exec(statement).first()
    return internship.visits if internship else []

@router.post("/{student_uid}/visits", response_model=InternshipVisit)
async def create_internship_visit(student_uid: str, visit_data: dict, session: Session = Depends(get_session), current_user: User = Depends(get_current_user)):
    statement = select(Internship).where(Internship.student_uid == student_uid, Internship.is_active == True)
    internship = session.exec(statement).first()
    if not internship: raise HTTPException(status_code=404)
    
    visit = InternshipVisit(internship_id=internship.id, date=visit_data.get("date", datetime.now()), type=visit_data.get("type", "SITE"), report_content=visit_data.get("report_content"))
    session.add(visit); session.commit(); session.refresh(visit)
    return visit

@router.post("/{student_uid}/generate-token")
async def generate_internship_token(student_uid: str, session: Session = Depends(get_session), current_user: User = Depends(get_current_user)):
    statement = select(Internship).where(Internship.student_uid == student_uid, Internship.is_active == True)
    internship = session.exec(statement).first()
    if not internship: raise HTTPException(status_code=404)
    
    internship.evaluation_token = str(uuid.uuid4())
    internship.token_expires_at = datetime.now() + timedelta(days=15)
    session.add(internship); session.commit(); session.refresh(internship)
    return {"token": internship.evaluation_token}

@router.post("/{student_uid}/evaluate")
async def save_internship_evaluation(student_uid: str, eval_data: dict, session: Session = Depends(get_session), current_user: User = Depends(get_current_user)):
    statement = select(Internship).where(Internship.student_uid == student_uid, Internship.is_active == True)
    internship = session.exec(statement).first()
    if not internship: raise HTTPException(status_code=404)

    role = eval_data.get("role")
    evaluations = eval_data.get("evaluations", [])
    
    # Nettoyage RÉEL des anciennes notes pour ce rôle
    old_evals_stmt = select(InternshipEvaluation).where(
        InternshipEvaluation.internship_id == internship.id, 
        InternshipEvaluation.evaluator_role == role
    )
    old_evals = session.exec(old_evals_stmt).all()
    for oe in old_evals:
        session.delete(oe)
    
    for item in evaluations:
        session.add(InternshipEvaluation(
            internship_id=internship.id, 
            evaluator_role=role, 
            criterion_id=item["criterion_id"], 
            score=item["score"], 
            comment=item.get("comment")
        ))
    
    if eval_data.get("finalize") and role == "TEACHER":
        internship.is_finalized = True
        session.add(internship)
    
    session.commit()
    return {"status": "success"}

@router.get("/{student_uid}/evaluations", response_model=List[InternshipEvaluation])
async def get_all_internship_evaluations(student_uid: str, session: Session = Depends(get_session)):
    statement = select(Internship).where(Internship.student_uid == student_uid, Internship.is_active == True)
    internship = session.exec(statement).first()
    if not internship: return []
    return session.exec(select(InternshipEvaluation).where(InternshipEvaluation.internship_id == internship.id)).all()
