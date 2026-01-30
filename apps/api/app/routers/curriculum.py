from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select
from typing import List
from ..database import get_session
from ..models import Competency, Activity, Resource, ResponsibilityMatrix, ResponsibilityEntityType, ResponsibilityType
from ..dependencies import get_current_user, require_staff
from pydantic import BaseModel
from fastapi import UploadFile, File
from ..services.pdf_parser import CurriculumPDFParser

router = APIRouter(tags=["Curriculum"])

# --- RESPONSIBILITY MATRIX ---

class RoleAssignment(BaseModel):
    user_id: str
    entity_type: ResponsibilityEntityType
    entity_id: str
    role_type: ResponsibilityType

@router.get("/responsibility")
def list_responsibilities(entity_type: ResponsibilityEntityType = None, entity_id: str = None, session: Session = Depends(get_session)):
    query = select(ResponsibilityMatrix)
    if entity_type: query = query.where(ResponsibilityMatrix.entity_type == entity_type)
    if entity_id: query = query.where(ResponsibilityMatrix.entity_id == entity_id)
    return session.exec(query).all()

@router.post("/assign-role")
def assign_role(data: RoleAssignment, session: Session = Depends(get_session), current_user: any = Depends(require_staff)):
    # Supprimer l'existant si on veut un seul OWNER
    if data.role_type == ResponsibilityType.OWNER:
        existing_owner = session.exec(select(ResponsibilityMatrix).where(
            ResponsibilityMatrix.entity_type == data.entity_type,
            ResponsibilityMatrix.entity_id == data.entity_id,
            ResponsibilityMatrix.role_type == ResponsibilityType.OWNER
        )).first()
        if existing_owner:
            session.delete(existing_owner)

    # Vérifier si cet utilisateur est déjà assigné
    existing = session.exec(select(ResponsibilityMatrix).where(
        ResponsibilityMatrix.user_id == data.user_id,
        ResponsibilityMatrix.entity_type == data.entity_type,
        ResponsibilityMatrix.entity_id == data.entity_id,
        ResponsibilityMatrix.role_type == data.role_type
    )).first()
    
    if not existing:
        new_assign = ResponsibilityMatrix(
            user_id=data.user_id, 
            entity_type=data.entity_type, 
            entity_id=data.entity_id, 
            role_type=data.role_type
        )
        session.add(new_assign)
        session.commit()
    return {"status": "success"}

@router.post("/unassign-role")
def unassign_role(data: RoleAssignment, session: Session = Depends(get_session), current_user: any = Depends(require_staff)):
    existing = session.exec(select(ResponsibilityMatrix).where(
        ResponsibilityMatrix.user_id == data.user_id,
        ResponsibilityMatrix.entity_type == data.entity_type,
        ResponsibilityMatrix.entity_id == data.entity_id,
        ResponsibilityMatrix.role_type == data.role_type
    )).first()
    if existing:
        session.delete(existing)
        session.commit()
    return {"status": "success"}

# --- CURRICULUM ---



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
    
    # Récupérer toutes les responsabilités
    all_responsibilities = session.exec(select(ResponsibilityMatrix)).all()
    
    result = []
    for a in acts:
        d = a.model_dump()
        d["learning_outcomes"] = [lo.model_dump() for lo in a.learning_outcomes]
        d["essential_components"] = [ce.model_dump() for ce in a.essential_components]
        
        # 1. Responsabilités directes sur l'activité
        act_resp = [r for r in all_responsibilities if r.entity_type == ResponsibilityEntityType.ACTIVITY and r.entity_id == str(a.id)]
        owner = next((r for r in act_resp if r.role_type == ResponsibilityType.OWNER), None)
        d["owner_id"] = owner.user_id if owner else None
        d["intervenants_identifies"] = [r.user_id for r in act_resp if r.role_type == ResponsibilityType.INTERVENANT]
        
        # 2. Intervenants de fait (responsables des ressources liées)
        res_codes = [r.strip() for r in a.resources.split(',')] if a.resources else []
        de_fait = set()
        for r_code in res_codes:
            r_resp = [r for r in all_responsibilities if r.entity_type == ResponsibilityEntityType.RESOURCE and r.entity_id == r_code]
            for resp in r_resp:
                de_fait.add(resp.user_id)
        
        # On enlève le owner et les intervenants déjà identifiés pour ne pas faire de doublons
        d["intervenants_de_fait"] = list(de_fait - {d["owner_id"]} - set(d["intervenants_identifies"]))
        
        result.append(d)
    return result

@router.get("/resources")
def list_resources(session: Session = Depends(get_session)):
    from sqlalchemy.orm import selectinload
    statement = select(Resource).options(selectinload(Resource.learning_outcomes))
    res = session.exec(statement).all()
    
    # Récupérer toutes les responsabilités pour les ressources
    responsibilities = session.exec(select(ResponsibilityMatrix).where(ResponsibilityMatrix.entity_type == ResponsibilityEntityType.RESOURCE)).all()
    
    result = []
    for r in res:
        d = r.model_dump()
        d["learning_outcomes"] = [lo.model_dump() for lo in r.learning_outcomes]
        
        # Trouver le responsable (OWNER)
        owner = next((r_resp for r_resp in responsibilities if r_resp.entity_id == r.code and r_resp.role_type == ResponsibilityType.OWNER), None)
        d["owner_id"] = owner.user_id if owner else None
        
        # Liste des intervenants
        d["intervenants_identifies"] = [r_resp.user_id for r_resp in responsibilities if r_resp.entity_id == r.code and r_resp.role_type == ResponsibilityType.INTERVENANT]
        
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

@router.patch("/resources/{res_id}")
def update_resource(res_id: int, res_data: dict, session: Session = Depends(get_session)):
    resource = session.get(Resource, res_id)
    if not resource: raise HTTPException(status_code=404, detail="Resource not found")
    for key, value in res_data.items():
        if hasattr(resource, key): setattr(resource, key, value)
    session.add(resource); session.commit(); session.refresh(resource)
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

@router.patch("/learning-outcomes/{lo_id}")
def update_learning_outcome(lo_id: int, lo_data: dict, session: Session = Depends(get_session), current_user: any = Depends(require_staff)):
    from ..models import LearningOutcome
    lo = session.get(LearningOutcome, lo_id)
    if not lo: raise HTTPException(status_code=404, detail="Learning Outcome not found")
    for key, value in lo_data.items():
        if key in ["label", "description"]:
            setattr(lo, key, value)
    session.add(lo); session.commit(); session.refresh(lo)
    return lo

@router.post("/verify-pdf")
async def verify_pdf_program(file: UploadFile = File(...), session: Session = Depends(get_session), current_user: any = Depends(require_staff)):
    """
    Parses a PDF program and compares it with the current database.
    Returns a report of discrepancies.
    """
    if not file.filename.lower().endswith('.pdf'):
        raise HTTPException(status_code=400, detail="File must be a PDF")

    content = await file.read()
    parser = CurriculumPDFParser(content)
    extracted_structure = parser.parse()

    # Fetch current DB state
    db_competencies = session.exec(select(Competency)).all() # Not used in simple comparison yet
    db_resources = session.exec(select(Resource)).all()
    db_activities = session.exec(select(Activity)).all()

    report = parser.compare_with_db(db_competencies, db_resources, db_activities)

    return {
        "status": "success",
        "extracted_stats": {
            "resources_count": len(extracted_structure["resources"]),
            "activities_count": len(extracted_structure["activities"])
        },
        "report": report
    }
