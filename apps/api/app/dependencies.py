from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from sqlmodel import Session, select
from .routers.auth import SECRET_KEY, ALGORITHM
from .database import get_session
from .models import User, UserRole

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")

async def get_current_user(token: str = Depends(oauth2_scheme), session: Session = Depends(get_session)):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
        
        # 1. Administrateur de secours (local)
        if username == "admin":
            return {"ldap_uid": "admin", "full_name": "Administrateur Local", "role": UserRole.SUPER_ADMIN}

        # 2. Recherche dans la base locale (utilisateurs dispatchés)
        statement = select(User).where(User.ldap_uid == username)
        user = session.exec(statement).first()
        
        # SÉCURITÉ CRITIQUE : Si l'utilisateur n'est pas en base OU s'il n'a pas de groupe assigné OU s'il est GUEST
        if not user or not user.group_id or user.role == UserRole.GUEST:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN, 
                detail="Accès refusé : vous n'avez pas été assigné à une promotion ou un rôle par l'administration."
            )
            
        return user

    except JWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")

def require_staff(current_user: any = Depends(get_current_user)):
    """
    Restrict access to STAFF (Prof, Admin, Direction).
    """
    role = current_user["role"] if isinstance(current_user, dict) else current_user.role
    
    allowed_roles = [
        UserRole.SUPER_ADMIN, UserRole.ADMIN, 
        UserRole.DEPT_HEAD, UserRole.ADMIN_STAFF,
        UserRole.PROFESSOR, UserRole.STUDY_DIRECTOR, UserRole.PROF_RESP_SAE
    ]
    
    if role not in allowed_roles:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, 
            detail="Accès réservé au personnel enseignant et administratif."
        )
    return current_user