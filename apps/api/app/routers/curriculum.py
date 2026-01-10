from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select
from typing import List
from ..database import get_session
from ..models import Competency, Activity, Resource
from ..dependencies import get_current_user

router = APIRouter(tags=["Curriculum"])

@router.get("/competencies")
def list_competencies(session: Session = Depends(get_session)):
    from sqlalchemy.orm import selectinload
    statement = select(Competency).options(
        selectinload(Competency.essential_components),
        selectinload(Competency.learning_outcomes)
    )
    comps = session.exec(statement).all()
    result = []
    for c in comps:
        d = c.model_dump()
        d["essential_components"] = [ce.model_dump() for ce in c.essential_components]
        d["learning_outcomes"] = [lo.model_dump() for lo in c.learning_outcomes]
        result.append(d)
    return result

@router.get("/activities")
def list_activities(session: Session = Depends(get_session)):
    from sqlalchemy.orm import selectinload
    statement = select(Activity).options(
        selectinload(Activity.learning_outcomes),
        selectinload(Activity.essential_components)
    )
    acts = session.exec(statement).all()
    result = []
    for a in acts:
        d = a.model_dump()
        d["learning_outcomes"] = [lo.model_dump() for lo in a.learning_outcomes]
        d["essential_components"] = [ce.model_dump() for ce in a.essential_components]
        result.append(d)
    return result

@router.get("/resources")
def list_resources(session: Session = Depends(get_session)):
    from sqlalchemy.orm import selectinload
    statement = select(Resource).options(selectinload(Resource.learning_outcomes))
    res = session.exec(statement).all()
    result = []
    for r in res:
        d = r.model_dump()
        d["learning_outcomes"] = [lo.model_dump() for lo in r.learning_outcomes]
        result.append(d)
    return result

@router.get("/resources/{code}")
def read_resource(code: str, pathway: str = None, session: Session = Depends(get_session)):
    query = select(Resource).where(Resource.code == code)

    if pathway:
        specific_res = session.exec(query.where(Resource.pathway == pathway)).first()
        if specific_res:
            return specific_res
        tc_res = session.exec(query.where(Resource.pathway == "Tronc Commun")).first()
        if tc_res:
            return tc_res

    resource = session.exec(query).first()
    if not resource:
        raise HTTPException(status_code=404, detail="Resource not found")
    return resource

@router.patch("/competencies/{comp_id}")
def update_competency(comp_id: int, comp_data: dict, session: Session = Depends(get_session)):
    comp = session.get(Competency, comp_id)
    if not comp: raise HTTPException(status_code=404, detail="Competency not found")
    for key, value in comp_data.items():
        if hasattr(comp, key): setattr(comp, key, value)
    session.add(comp); session.commit(); session.refresh(comp)
    return comp

@router.patch("/activities/{act_id}")
def update_activity(act_id: int, act_data: dict, session: Session = Depends(get_session)):
    act = session.get(Activity, act_id)
    if not act: raise HTTPException(status_code=404, detail="Activity not found")
    for key, value in act_data.items():
        if key in ["label", "description", "resources"]:
            setattr(act, key, value)
    session.add(act); session.commit(); session.refresh(act)
    return act
