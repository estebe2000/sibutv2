from fastapi import APIRouter, Request, Depends
from fastapi.responses import HTMLResponse, RedirectResponse
from sqlmodel import Session, select
from ..models import User

router = APIRouter()

def get_current_user_from_session(request: Request):
    user_session = request.session.get('user')
    if not user_session:
        return None
    return user_session

@router.get("/dashboard", response_class=HTMLResponse)
async def mobile_dashboard(request: Request):
    """
    Tableau de bord mobile pour les étudiants et tuteurs.
    """
    user_session = get_current_user_from_session(request)
    if not user_session:
        return RedirectResponse(url='/login')

    context = {
        "request": request,
        "user_session": user_session,
        "internships": []
    }
    from ..main import templates
    return templates.TemplateResponse("mobile/dashboard.html", context)

@router.get("/evaluations", response_class=HTMLResponse)
async def mobile_evaluations(request: Request):
    """
    Vue mobile pour le remplissage des évaluations (Tuteur et Élève).
    """
    user_session = get_current_user_from_session(request)
    if not user_session:
        return RedirectResponse(url='/login')

    context = {
        "request": request,
        "user_session": user_session,
        "evaluations_pending": []
    }
    from ..main import templates
    return templates.TemplateResponse("mobile/evaluations.html", context)

@router.get("/ai", response_class=HTMLResponse)
async def mobile_ai_assistant(request: Request):
    """
    Vue mobile pour l'assistant IA.
    """
    user_session = get_current_user_from_session(request)
    if not user_session:
        return RedirectResponse(url='/login')

    context = {
        "request": request,
        "user_session": user_session
    }
    from ..main import templates
    return templates.TemplateResponse("mobile/ai_assistant.html", context)
