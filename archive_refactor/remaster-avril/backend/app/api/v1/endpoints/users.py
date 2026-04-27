from fastapi import APIRouter, Request, Depends, HTTPException
from sqlmodel import Session, select
from sqlalchemy.orm import selectinload
from app.core.security import prof_or_admin, engine
from app.models.models import User, Resource, Activity, ActivityGroup

router = APIRouter(tags=["users"])

@router.get("/student/{ldap_uid}", dependencies=[Depends(prof_or_admin)])
async def get_student_details(ldap_uid: str):
    with Session(engine) as session:
        s = session.exec(select(User).where(User.ldap_uid == ldap_uid)).first()
        return {"ldap_uid": s.ldap_uid, "full_name": s.full_name, "email": s.email, "nip": s.nip} if s else {"error": "Non trouvé"}

@router.get("/teacher/{ldap_uid}", dependencies=[Depends(prof_or_admin)])
async def get_teacher_details(ldap_uid: str):
    with Session(engine) as session:
        t = session.exec(select(User).where(User.ldap_uid == ldap_uid)).first()
        if not t: return {"error": "Non trouvé"}
        
        res = session.exec(select(Resource).where((Resource.responsible_uid == t.ldap_uid) | (Resource.responsible == t.full_name))).all()
        global_acts = session.exec(select(Activity).where(Activity.responsible_id == t.id)).all()
        tutored_groups = session.exec(select(ActivityGroup).options(
            selectinload(ActivityGroup.activity), 
            selectinload(ActivityGroup.students)
        ).where(ActivityGroup.tutor_id == t.id)).all()
        
        return {
            "ldap_uid": t.ldap_uid, 
            "full_name": t.full_name, 
            "email": t.email, 
            "phone": t.phone, 
            "roles": t.roles_list, 
            "managed_activities": [{"code": a.code, "label": a.label} for a in global_acts], 
            "tutored_groups": [{"activity_code": g.activity.code, "group_name": g.name, "students": [s.full_name for s in g.students]} for g in tutored_groups], 
            "resources": [{"code": r.code, "label": r.label} for r in res]
        }
