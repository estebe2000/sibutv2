from fastapi import APIRouter, HTTPException, Depends
from sqlmodel import Session, select
from typing import List, Optional
from datetime import datetime
from ..database import get_session
from ..models import Internship, InternshipEvaluation, EvaluationRubric, Activity, ActivityType

router = APIRouter()

@router.get("/{token}")
async def get_public_evaluation(token: str, session: Session = Depends(get_session)):
    """Récupère la grille d'évaluation pour un tuteur externe via son Magic Link"""
    # 1. Trouver le stage associé au token
    statement = select(Internship).where(Internship.evaluation_token == token)
    internship = session.exec(statement).first()
    
    if not internship:
        raise HTTPException(status_code=404, detail="Lien invalide ou expiré")
    
    if internship.token_expires_at and internship.token_expires_at < datetime.now():
        raise HTTPException(status_code=403, detail="Ce lien a expiré")

    # 2. Trouver la grille d'évaluation pour les stages
    # Pour la démo, on prend la première grille liée à une activité de type STAGE
    act_statement = select(Activity).where(Activity.type == ActivityType.STAGE)
    stage_activity = session.exec(act_statement).first()
    
    if not stage_activity:
        raise HTTPException(status_code=404, detail="Aucune grille d'évaluation de stage configurée")
    
    rubric_statement = select(EvaluationRubric).where(EvaluationRubric.activity_id == stage_activity.id)
    rubric = session.exec(rubric_statement).first()
    
    if not rubric:
         raise HTTPException(status_code=404, detail="Grille d'évaluation non trouvée")

    return {
        "internship_id": internship.id,
        "student_name": internship.student_uid, # On pourrait joindre avec User pour le nom complet
        "company": internship.company_name,
        "rubric": {
            "name": rubric.name,
            "criteria": rubric.criteria
        }
    }

@router.post("/{token}")
async def submit_public_evaluation(token: str, evaluations: List[dict], session: Session = Depends(get_session)):
    """Enregistre l'évaluation du maître de stage"""
    statement = select(Internship).where(Internship.evaluation_token == token)
    internship = session.exec(statement).first()
    
    if not internship:
        raise HTTPException(status_code=404, detail="Lien invalide")

    # Enregistrement des notes
    for eval_item in evaluations:
        new_eval = InternshipEvaluation(
            internship_id=internship.id,
            evaluator_role="PRO",
            criterion_id=eval_item["criterion_id"],
            score=eval_item["score"],
            comment=eval_item.get("comment")
        )
        session.add(new_eval)

    # Invalidation du token après soumission pour la démo (optionnel selon le besoin)
    # internship.evaluation_token = None 
    
    session.add(internship)
    session.commit()
    
    return {"status": "success", "message": "Évaluation enregistrée avec succès"}
