from fastapi import APIRouter, Request, Depends, HTTPException
from sqlmodel import Session, select, func
from sqlalchemy.orm import selectinload
from app.core.security import admin_only, engine
from app.models.models import Activity, EvaluationRubric, RubricCriterion, LearningOutcome, Competency
import json

router = APIRouter(prefix="/evaluations", tags=["evaluations"])

@router.post("/generate/{activity_id}", dependencies=[Depends(admin_only)])
async def generate_default_rubric(activity_id: int):
    with Session(engine) as session:
        activity = session.exec(select(Activity).options(
            selectinload(Activity.learning_outcomes).selectinload(LearningOutcome.competency)
        ).where(Activity.id == activity_id)).first()
        
        if not activity: raise HTTPException(status_code=404, detail="Activité introuvable")
        existing = session.exec(select(EvaluationRubric).where(EvaluationRubric.activity_id == activity_id)).first()
        if existing: raise HTTPException(status_code=400, detail="Une grille existe déjà")
            
        rubric = EvaluationRubric(activity_id=activity_id, name=f"Grille d'évaluation : {activity.code}")
        session.add(rubric)
        session.flush() # Récupère l'ID sans commiter
        
        if not activity.learning_outcomes:
            session.add(RubricCriterion(rubric_id=rubric.id, label="Evaluation Globale / Participation", coefficient=1.0, max_points=20.0))
        else:
            for ac in activity.learning_outcomes:
                coef = 2.0 if (activity.level > 1 and ac.competency.pathway != "Tronc Commun") else 1.0
                session.add(RubricCriterion(rubric_id=rubric.id, learning_outcome_id=ac.id, label=f"{ac.code} - {ac.label}", coefficient=coef, max_points=20.0))
            
        session.commit()
        return {"status": "success", "rubric_id": rubric.id}

@router.post("/generate-all", dependencies=[Depends(admin_only)])
async def generate_all_rubrics():
    print("🚀 DÉMARRAGE GÉNÉRATION MASSIVE...")
    created = 0
    with Session(engine) as session:
        activities = session.exec(select(Activity).options(
            selectinload(Activity.learning_outcomes).selectinload(LearningOutcome.competency)
        )).all()
        
        for act in activities:
            existing = session.exec(select(EvaluationRubric).where(EvaluationRubric.activity_id == act.id)).first()
            if existing: continue
            
            rubric = EvaluationRubric(activity_id=act.id, name=f"Grille : {act.code}")
            session.add(rubric)
            session.flush() # Crucial pour isoler les critères
            
            if not act.learning_outcomes:
                session.add(RubricCriterion(rubric_id=rubric.id, label="Evaluation Globale / Participation", coefficient=1.0, max_points=20.0))
            else:
                for ac in act.learning_outcomes:
                    coef = 2.0 if (act.level > 1 and ac.competency.pathway != "Tronc Commun") else 1.0
                    session.add(RubricCriterion(rubric_id=rubric.id, learning_outcome_id=ac.id, label=f"{ac.code} - {ac.label}", coefficient=coef, max_points=20.0))
            created += 1
            
        session.commit()
    print(f"✅ {created} grilles certifiées générées.")
    return {"status": "success", "created": created}
