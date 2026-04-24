from fastapi import APIRouter, Request, Depends
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
from sqlmodel import Session, select
from sqlalchemy.orm import selectinload
import os
from app.core.security import admin_only, prof_or_admin, engine
from app.models.models import User, UserRole, Activity, Resource, Announcement, LearningOutcome, Promotion

router = APIRouter(prefix="/admin", tags=["admin_views"])
templates = Jinja2Templates(directory=os.path.join(os.path.dirname(os.path.dirname(__file__)), "templates"))

@router.get("/activities")
async def admin_activities(request: Request, user: User = Depends(prof_or_admin)):
    active_role = request.session.get('active_role') or user.role.value
    with Session(engine) as session:
        activities = session.exec(select(Activity).options(selectinload(Activity.responsible_user)).order_by(Activity.code)).all()
        resources = session.exec(select(Resource).order_by(Resource.code)).all()
        teachers = session.exec(select(User).where(User.role != UserRole.STUDENT).order_by(User.full_name)).all()
        return templates.TemplateResponse("admin_activities.html", {"request": request, "user": user, "active_role": active_role, "activities": activities, "resources": resources, "teachers": teachers})

@router.get("/users")
async def admin_users(request: Request, user: User = Depends(admin_only)):
    active_role = request.session.get('active_role') or user.role.value
    with Session(engine) as session:
        all_users = session.exec(select(User).where(User.role != UserRole.STUDENT).order_by(User.full_name)).all()
        return templates.TemplateResponse("admin_users.html", {"request": request, "user": user, "active_role": active_role, "all_users": all_users})

@router.get("/matrix")
async def admin_matrix(request: Request, user: User = Depends(admin_only)):
    active_role = request.session.get('active_role') or user.role.value
    with Session(engine) as session:
        announcements = session.exec(select(Announcement).order_by(Announcement.created_at.desc()).limit(10)).all()
        return templates.TemplateResponse("admin_matrix.html", {"request": request, "user": user, "active_role": active_role, "announcements": announcements})

@router.get("/synchro-scodoc")
async def synchro_scodoc(request: Request, user: User = Depends(admin_only)):
    return templates.TemplateResponse("dispatch_students.html", {"request": request, "user": user, "active_role": "ADMIN"})

@router.get("/ac-editor")
async def admin_ac_editor(request: Request, user: User = Depends(admin_only)):
    active_role = request.session.get('active_role') or user.role.value
    with Session(engine) as session:
        acs = session.exec(select(LearningOutcome).order_by(LearningOutcome.code)).all()
        return templates.TemplateResponse("ac_editor.html", {"request": request, "user": user, "active_role": active_role, "acs": acs})

@router.post("/ac-editor-save")
async def admin_ac_save(request: Request, user: User = Depends(admin_only)):
    f = await request.form()
    ac_id = int(f.get("ac_id"))
    with Session(engine) as session:
        ac = session.get(LearningOutcome, ac_id)
        if ac: 
            ac.description = f.get("description")
            session.add(ac)
            session.commit()
    return HTMLResponse(content="OK")
