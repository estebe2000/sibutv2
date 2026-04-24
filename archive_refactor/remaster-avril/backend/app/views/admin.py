from fastapi import APIRouter, Request, Depends, HTTPException
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.templating import Jinja2Templates
from sqlmodel import Session, select, func
from sqlalchemy.orm import selectinload
import os, json
from app.core.security import admin_only, prof_or_admin, engine
from app.models.models import User, UserRole, Activity, Resource, Announcement, LearningOutcome, Promotion, Group, ActivityGroup

router = APIRouter(prefix="/admin", tags=["admin_views"])
templates = Jinja2Templates(directory=os.path.join(os.path.dirname(os.path.dirname(__file__)), "templates"))

@router.get("/activities")
async def admin_activities(request: Request, user: User = Depends(prof_or_admin)):
    active_role = request.session.get('active_role') or user.role.value
    with Session(engine) as session:
        activities = session.exec(select(Activity).options(selectinload(Activity.responsible_user)).order_by(Activity.code)).all()
        resources = session.exec(select(Resource).order_by(Resource.code)).all()
        teachers = session.exec(select(User).where(User.role != UserRole.STUDENT).order_by(User.full_name)).all()
        return templates.TemplateResponse(request, "admin_activities.html", {"request": request, "user": user, "active_role": active_role, "activities": activities, "resources": resources, "teachers": teachers})

@router.get("/activities/{act_id}")
async def admin_activity_detail(request: Request, act_id: int, user: User = Depends(prof_or_admin)):
    active_role = request.session.get('active_role') or user.role.value
    with Session(engine) as session:
        activity = session.exec(select(Activity).options(
            selectinload(Activity.responsible_user),
            selectinload(Activity.activity_groups).selectinload(ActivityGroup.tutor),
            selectinload(Activity.activity_groups).selectinload(ActivityGroup.students),
            selectinload(Activity.learning_outcomes)
        ).where(Activity.id == act_id)).first()
        if not activity: raise HTTPException(status_code=404)
        
        teachers = session.exec(select(User).where(User.role != UserRole.STUDENT).order_by(User.full_name)).all()
        return templates.TemplateResponse(request, "admin_activity_detail.html", {"request": request, "user": user, "active_role": active_role, "activity": activity, "teachers": teachers})

@router.post("/activities/{act_id}/responsible")
async def admin_activity_responsible(request: Request, act_id: int, user: User = Depends(prof_or_admin)):
    f = await request.form(); resp_id = f.get("responsible_id"); uid = f.get("ldap_uid"); name = f.get("full_name")
    with Session(engine) as session:
        act = session.get(Activity, act_id)
        if act:
            t = session.get(User, int(resp_id)) if resp_id else session.exec(select(User).where(User.ldap_uid == uid)).first()
            if not t and uid: 
                t = User(ldap_uid=uid, full_name=name or uid, role=UserRole.PROFESSOR, email=f"{uid}@univ-lehavre.fr")
                session.add(t); session.commit(); session.refresh(t)
            if t: act.responsible_id = t.id; session.add(act); session.commit()
    return HTMLResponse(content="OK")

@router.post("/activities/{act_id}/groups/add")
async def admin_activity_group_add(act_id: int, user: User = Depends(prof_or_admin)):
    with Session(engine) as session:
        c = session.exec(select(func.count(ActivityGroup.id)).where(ActivityGroup.activity_id == act_id)).one()
        session.add(ActivityGroup(name=f"Groupe {c + 1}", activity_id=act_id))
        session.commit()
    return RedirectResponse(url=f"/admin/activities/{act_id}", status_code=303)

@router.post("/groups/{group_id}/tutor")
async def admin_group_tutor(request: Request, group_id: int, user: User = Depends(prof_or_admin)):
    f = await request.form(); tid = f.get("tutor_id"); uid = f.get("ldap_uid"); name = f.get("full_name")
    with Session(engine) as session:
        g = session.get(ActivityGroup, group_id)
        if g:
            t = session.get(User, int(tid)) if tid else session.exec(select(User).where(User.ldap_uid == uid)).first()
            if not t and uid: 
                t = User(ldap_uid=uid, full_name=name or uid, role=UserRole.PROFESSOR, email=f"{uid}@univ-lehavre.fr")
                session.add(t); session.commit(); session.refresh(t)
            if t: g.tutor_id = t.id; session.add(g); session.commit()
    return HTMLResponse(content="OK")

@router.get("/users")
async def admin_users(request: Request, user: User = Depends(admin_only)):
    active_role = request.session.get('active_role') or user.role.value
    with Session(engine) as session:
        all_users = session.exec(select(User).where(User.role != UserRole.STUDENT).order_by(User.full_name)).all()
        return templates.TemplateResponse(request, "admin_users.html", {"request": request, "user": user, "active_role": active_role, "all_users": all_users})

@router.get("/matrix")
async def admin_matrix(request: Request, user: User = Depends(admin_only)):
    active_role = request.session.get('active_role') or user.role.value
    with Session(engine) as session:
        announcements = session.exec(select(Announcement).order_by(Announcement.created_at.desc()).limit(10)).all()
        return templates.TemplateResponse(request, "admin_matrix.html", {"request": request, "user": user, "active_role": active_role, "announcements": announcements})

@router.get("/synchro-scodoc")
async def synchro_scodoc(request: Request, user: User = Depends(admin_only)):
    return templates.TemplateResponse(request, "dispatch_students.html", {"request": request, "user": user, "active_role": "ADMIN"})

@router.get("/ac-editor")
async def admin_ac_editor(request: Request, user: User = Depends(admin_only)):
    active_role = request.session.get('active_role') or user.role.value
    with Session(engine) as session:
        acs = session.exec(select(LearningOutcome).options(selectinload(LearningOutcome.competency)).order_by(LearningOutcome.code)).all()
        return templates.TemplateResponse(request, "ac_editor.html", {"request": request, "user": user, "active_role": active_role, "learning_outcomes": acs})

@router.post("/ac-editor-save")
async def admin_ac_save(request: Request, user: User = Depends(admin_only)):
    f = await request.form()
    ac_id = int(f.get("ac_id"))
    new_desc = f.get("description")
    
    with Session(engine) as session:
        ac = session.get(LearningOutcome, ac_id)
        if ac: 
            ac.description = new_desc
            session.add(ac)
            session.commit()
            session.refresh(ac)
            print(f"✅ AC {ac.code} mis à jour par {user.ldap_uid}")
            return HTMLResponse(content="OK")
    
    raise HTTPException(status_code=404, detail="AC non trouvé")
