from fastapi import APIRouter, HTTPException, Depends
from sqlmodel import Session, select
from typing import List, Optional
from pydantic import BaseModel
from ..database import get_session
from ..models import Activity, EvaluationRubric, RubricCriterion, User, ActivityType
from ..dependencies import require_staff
from sqlalchemy.orm import selectinload

router = APIRouter()

@router.get("/activities")
async def list_activities_with_rubrics(session: Session = Depends(get_session)):
    """Liste toutes les activités groupées par type avec leurs grilles"""
    activities = session.exec(select(Activity)).all()
    result = []
    
    for act in activities:
        rubrics = session.exec(select(EvaluationRubric).where(EvaluationRubric.activity_id == act.id)).all()
        act_data = {
            "id": act.id,
            "code": act.code,
            "label": act.label,
            "type": act.type,
            "rubrics": []
        }
        for r in rubrics:
            criteria = session.exec(select(RubricCriterion).where(RubricCriterion.rubric_id == r.id)).all()
            act_data["rubrics"].append({
                "id": r.id,
                "name": r.name,
                "total_points": r.total_points,
                "criteria": [c.model_dump() for c in criteria]
            })
        result.append(act_data)
    return result

class RubricUpdate(BaseModel):
    name: Optional[str] = None
    total_points: Optional[float] = None

class CriterionCreate(BaseModel):
    label: str
    weight: float = 1.0
    ac_id: Optional[int] = None
    ce_id: Optional[int] = None

@router.get("/{activity_id}/rubrics")
async def list_activity_rubrics(activity_id: int, session: Session = Depends(get_session)):
    """Liste les grilles avec chargement explicite des critères"""
    statement = (
        select(EvaluationRubric)
        .where(EvaluationRubric.activity_id == activity_id)
    )
    rubrics = session.exec(statement).all()
    
    result = []
    for r in rubrics:
        # On charge manuellement les critères pour chaque grille pour être CERTAIN qu'ils sont là
        stmt_crit = select(RubricCriterion).where(RubricCriterion.rubric_id == r.id)
        criteria = session.exec(stmt_crit).all()
        
        result.append({
            "id": r.id,
            "name": r.name,
            "activity_id": r.activity_id,
            "total_points": r.total_points,
            "criteria": [c.model_dump() for c in criteria]
        })
    return result

@router.post("/{activity_id}/rubrics")
async def create_rubric(activity_id: int, name: str, total_points: float = 20.0, session: Session = Depends(get_session)):
    rubric = EvaluationRubric(activity_id=activity_id, name=name, total_points=total_points)
    session.add(rubric)
    session.commit()
    session.refresh(rubric)
    return rubric

@router.patch("/rubrics/{rubric_id}")
async def update_rubric(rubric_id: int, update: RubricUpdate, session: Session = Depends(get_session)):
    rubric = session.get(EvaluationRubric, rubric_id)
    if not rubric: raise HTTPException(status_code=404)
    if update.name is not None: rubric.name = update.name
    if update.total_points is not None: rubric.total_points = update.total_points
    session.add(rubric)
    session.commit()
    session.refresh(rubric)
    return rubric

@router.delete("/rubrics/{rubric_id}")
async def delete_rubric(rubric_id: int, session: Session = Depends(get_session)):
    # Nettoyer les critères d'abord
    stmt = select(RubricCriterion).where(RubricCriterion.rubric_id == rubric_id)
    criteria = session.exec(stmt).all()
    for c in criteria: session.delete(c)
    
    rubric = session.get(EvaluationRubric, rubric_id)
    if rubric:
        session.delete(rubric)
        session.commit()
    return {"status": "success"}

@router.post("/rubrics/{rubric_id}/criteria")
async def add_criterion(rubric_id: int, crit: CriterionCreate, session: Session = Depends(get_session)):
    criterion = RubricCriterion(
        rubric_id=rubric_id, 
        label=crit.label, 
        weight=crit.weight, 
        ac_id=crit.ac_id, 
        ce_id=crit.ce_id
    )
    session.add(criterion)
    session.commit()
    session.refresh(criterion)
    return criterion

class CriterionUpdate(BaseModel):
    label: Optional[str] = None
    weight: Optional[float] = None

@router.patch("/criteria/{criterion_id}")
async def update_criterion(criterion_id: int, update: CriterionUpdate, session: Session = Depends(get_session)):
    criterion = session.get(RubricCriterion, criterion_id)
    if not criterion: raise HTTPException(status_code=404)
    if update.label is not None: criterion.label = update.label
    if update.weight is not None: criterion.weight = update.weight
    session.add(criterion)
    session.commit()
    session.refresh(criterion)
    return criterion

@router.delete("/criteria/{criterion_id}")
async def delete_criterion(criterion_id: int, session: Session = Depends(get_session)):
    criterion = session.get(RubricCriterion, criterion_id)
    if criterion:
        session.delete(criterion)
        session.commit()
    return {"status": "success"}
