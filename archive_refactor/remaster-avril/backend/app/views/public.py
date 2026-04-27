from fastapi import APIRouter, Request
from fastapi.responses import RedirectResponse
from app.core.oauth import oauth
from app.core.config import settings

router = APIRouter(tags=["public"])

@router.get("/login")
async def login(request: Request):
    redirect_uri = f"https://hub.{settings.DOMAIN}/auth"
    return await oauth.keycloak.authorize_redirect(request, redirect_uri)

@router.get("/auth")
async def auth(request: Request):
    token = await oauth.keycloak.authorize_access_token(request)
    user = token.get('userinfo')
    if user:
        request.session['user'] = user
    return RedirectResponse(url='/')

@router.get("/logout")
async def logout(request: Request):
    request.session.clear()
    return RedirectResponse(url=f"https://auth.{settings.DOMAIN}/realms/{settings.KEYCLOAK_REALM}/protocol/openid-connect/logout?client_id={settings.KEYCLOAK_CLIENT_ID}&post_logout_redirect_uri=https://hub.{settings.DOMAIN}/")
