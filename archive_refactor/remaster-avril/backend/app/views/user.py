from fastapi import APIRouter, Request, Depends
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.templating import Jinja2Templates
from sqlmodel import Session, select, func
from sqlalchemy.orm import selectinload
import os
from app.core.security import require_auth, engine, get_current_db_user
from app.models.models import User, UserRole, Activity, Competency, Promotion, Group, Resource, Announcement, LearningOutcome

router = APIRouter(tags=["user"])
templates = Jinja2Templates(directory=os.path.join(os.path.dirname(os.path.dirname(__file__)), "templates"))

@router.get("/")
async def index(request: Request, user: User = Depends(require_auth)):
    active_role = request.session.get('active_role') or user.role.value
    with Session(engine) as session:
        stats = {
            "users": session.exec(select(func.count(User.id))).one(), 
            "activities": session.exec(select(func.count(Activity.id))).one(), 
            "resources": session.exec(select(func.count(Resource.id))).one()
        }
        dashboard_data = {
            "recent_activities": session.exec(select(Activity).order_by(Activity.id.desc()).limit(5)).all(),
            "users_count": stats["users"],
            "sae_count": stats["activities"],
            "resources_count": stats["resources"]
        }
        announcements = session.exec(select(Announcement).order_by(Announcement.created_at.desc()).limit(5)).all()
        news = [{"sender": a.author_uid, "content": f"**{a.title}**<br>{a.content}", "timestamp": a.created_at} for a in announcements]
        return templates.TemplateResponse(request, "dashboard.html", {"request": request, "user": user, "active_role": active_role, "stats": stats, "data": dashboard_data, "news": news})

@router.get("/referentiel")
async def referentiel(request: Request, user: User = Depends(require_auth)):
    active_role = request.session.get('active_role') or user.role.value
    with Session(engine) as session:
        competencies = session.exec(select(Competency).options(
            selectinload(Competency.learning_outcomes).selectinload(LearningOutcome.activities), 
            selectinload(Competency.learning_outcomes).selectinload(LearningOutcome.resources), 
            selectinload(Competency.essential_components)
        ).order_by(Competency.code)).all()
        activities = session.exec(select(Activity).options(selectinload(Activity.learning_outcomes)).order_by(Activity.code)).all()
        resources = session.exec(select(Resource).options(selectinload(Resource.learning_outcomes)).order_by(Resource.code)).all()
        pathways = session.exec(select(Competency.pathway).distinct()).all()
        return templates.TemplateResponse(request, "referentiel.html", {"request": request, "user": user, "active_role": active_role, "competencies": competencies, "activities": activities, "resources": resources, "pathways": pathways})

@router.get("/effectifs")
async def effectifs(request: Request, user: User = Depends(require_auth)):
    active_role = request.session.get('active_role') or user.role.value
    with Session(engine) as session:
        promotions = session.exec(select(Promotion).options(selectinload(Promotion.users), selectinload(Promotion.groups))).all()
        return templates.TemplateResponse(request, "effectifs.html", {
            "request": request, "user": user, "active_role": active_role, 
            "promos_by_level": {
                1: next((p for p in promotions if p.entry_year == 2026), None), 
                2: next((p for p in promotions if p.entry_year == 2025), None), 
                3: next((p for p in promotions if p.entry_year == 2024), None)
            }, 
            "total_users": sum(len(p.users) for p in promotions)
        })

@router.get("/ai-assistant")
async def ai_assistant_view(request: Request, user: User = Depends(require_auth)):
    return templates.TemplateResponse(request, "ai_assistant.html", {"request": request, "user": user, "active_role": request.session.get('active_role') or user.role.value})

@router.get("/settings")
async def settings_view(request: Request, user: User = Depends(require_auth)):
    return templates.TemplateResponse(request, "settings.html", {"request": request, "user": user, "active_role": request.session.get('active_role') or user.role.value})

@router.get("/switch-role/{role}")
async def switch_role(request: Request, role: str):
    db_user = await get_current_db_user(request)
    if db_user: request.session['active_role'] = role
    return RedirectResponse(url='/')
