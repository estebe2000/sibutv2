from fastapi import APIRouter, Request, Depends, HTTPException
from sqlmodel import Session, select, func
from app.core.security import admin_only, prof_or_admin, engine
from app.models.models import User, UserRole, Resource, Group, Promotion
import json

router = APIRouter(prefix="/dispatch", tags=["dispatch"])

@router.patch("/resources/{res_id}", dependencies=[Depends(prof_or_admin)])
async def dispatch_resource_save(res_id: int, request: Request):
    data = await request.json()
    uid = data.get("responsible_uid")
    name = data.get("responsible")
    
    with Session(engine) as session:
        res = session.get(Resource, res_id)
        if not res:
            raise HTTPException(status_code=404, detail="Ressource non trouvée")
            
        teacher = session.exec(select(User).where(User.ldap_uid == uid)).first()
        if not teacher and uid:
            teacher = User(
                ldap_uid=uid, 
                full_name=name or uid, 
                role=UserRole.PROFESSOR, 
                email=f"{uid}@univ-lehavre.fr"
            )
            session.add(teacher)
            session.commit()
            session.refresh(teacher)
            
        if teacher:
            res.responsible_uid = teacher.ldap_uid
            res.responsible = teacher.full_name
            session.add(res)
            session.commit()
            
    return {"status": "success"}

@router.get("/groups/{group_id}/students", dependencies=[Depends(prof_or_admin)])
async def get_group_students(group_id: int):
    with Session(engine) as session:
        users = session.exec(select(User).where(User.group_id == group_id)).all()
        return [{"ldap_uid": u.ldap_uid, "full_name": u.full_name} for u in users]

@router.get("/groups/all", dependencies=[Depends(prof_or_admin)])
async def get_all_groups():
    with Session(engine) as session:
        groups = session.exec(select(Group)).all()
        return [{"id": g.id, "name": g.name, "pathway": g.pathway} for g in groups]

@router.patch("/students/{student_uid}/move", dependencies=[Depends(admin_only)])
async def move_student(student_uid: str, request: Request):
    data = await request.json()
    target_id = data.get("target_group_id")
    with Session(engine) as session:
        user = session.exec(select(User).where(User.ldap_uid == student_uid)).first()
        if user:
            user.group_id = int(target_id)
            session.add(user)
            session.commit()
    return {"status": "success"}

@router.delete("/students/{student_uid}/remove-group", dependencies=[Depends(admin_only)])
async def remove_student_from_group(student_uid: str):
    with Session(engine) as session:
        user = session.exec(select(User).where(User.ldap_uid == student_uid)).first()
        if user:
            user.group_id = None
            session.add(user)
            session.commit()
    return {"status": "success"}

@router.delete("/groups/{group_id}", dependencies=[Depends(admin_only)])
async def delete_promo_group(group_id: int):
    with Session(engine) as session:
        group = session.get(Group, group_id)
        if group:
            # On détache les étudiants
            session.exec(func.update(User).where(User.group_id == group_id).values(group_id=None))
            session.delete(group)
            session.commit()
    return {"status": "success"}

@router.post("/promotions/{promo_id}/groups/add", dependencies=[Depends(admin_only)])
async def add_promo_group(promo_id: int):
    with Session(engine) as session:
        count = session.exec(select(func.count(Group.id)).where(Group.promotion_id == promo_id)).one()
        session.add(Group(
            name=f"GR.{count+1} (FI)", 
            promotion_id=promo_id, 
            pathway="Tronc Commun", 
            year=2026, 
            academic_year="2025-2026", 
            formation_type="FI"
        ))
        session.commit()
    return {"status": "success"}
