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
    print(f"🗑️ TENTATIVE SUPPRESSION GROUPE ID: {group_id}")
    with Session(engine) as session:
        group = session.get(Group, group_id)
        if group:
            print(f"🔗 Détachement des étudiants du groupe {group.name}...")
            # On détache les étudiants via une requête directe pour plus de fiabilité
            from sqlalchemy import update
            session.execute(update(User).where(User.group_id == group_id).values(group_id=None))
            
            print(f"🔥 Suppression du groupe {group.name}...")
            session.delete(group)
            session.commit()
            print("✅ GROUPE SUPPRIMÉ.")
            return {"status": "success"}
    print(f"❌ Échec: Groupe {group_id} non trouvé.")
    raise HTTPException(status_code=404, detail="Groupe non trouvé")

@router.post("/promotions/{promo_id}/groups/add", dependencies=[Depends(admin_only)])
async def add_promo_group(promo_id: int, request: Request):
    data = await request.json()
    name = data.get("name")
    f_type = data.get("type", "FI")
    
    print(f"➕ TENTATIVE AJOUT GROUPE '{name}' ({f_type}) POUR PROMO ID: {promo_id}")
    with Session(engine) as session:
        promo = session.get(Promotion, promo_id)
        if not promo:
            raise HTTPException(status_code=404, detail="Promotion non trouvée")
            
        new_group = Group(
            name=name or f"Nouveau Groupe", 
            promotion_id=promo_id, 
            pathway="Tronc Commun", 
            year=promo.entry_year, 
            academic_year="2025-2026", 
            formation_type=f_type
        )
        session.add(new_group)
        session.commit()
        print(f"✅ GROUPE CRÉÉ: {new_group.name} (ID: {new_group.id})")
    return {"status": "success"}
