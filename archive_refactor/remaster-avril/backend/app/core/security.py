from fastapi import Request, Depends, HTTPException
from fastapi.responses import RedirectResponse
from sqlmodel import Session, select, create_engine
from .config import settings
from ..models.models import User, UserRole
import json

engine = create_engine(settings.DATABASE_URL)

class AuthRequiredException(Exception):
    pass

async def auth_exception_handler(request: Request, exc: AuthRequiredException):
    return RedirectResponse(url='/login')

async def get_current_db_user(request: Request):
    user_session = request.session.get('user')
    if not user_session: return None
    username = user_session.get('preferred_username')
    with Session(engine) as session:
        db_user = session.exec(select(User).where(User.ldap_uid == username)).first()
        if not db_user:
            db_user = User(
                ldap_uid=username, 
                full_name=user_session.get('name', username), 
                email=user_session.get('email', f"{username}@univ-lehavre.fr"), 
                role=UserRole.GUEST, 
                roles_json='["GUEST"]'
            )
            session.add(db_user)
            session.commit()
            session.refresh(db_user)
        return db_user

async def require_auth(request: Request, user: User = Depends(get_current_db_user)):
    if not user:
        raise AuthRequiredException()
    return user

class RoleChecker:
    def __init__(self, allowed_roles: list[str]):
        self.allowed_roles = allowed_roles
    
    def __call__(self, request: Request, user: User = Depends(get_current_db_user)):
        if not user:
            raise AuthRequiredException()
        active_role = request.session.get('active_role') or user.role.value
        if active_role not in self.allowed_roles and "ADMIN" not in (user.roles_list or []):
            raise HTTPException(status_code=403, detail="Accès refusé : privilèges insuffisants")
        return user

# Dépendances réutilisables
admin_only = RoleChecker(["ADMIN"])
prof_or_admin = RoleChecker(["ADMIN", "PROFESSOR"])
any_auth = require_auth
