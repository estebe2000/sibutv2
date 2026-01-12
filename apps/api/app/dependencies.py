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
        
        # 1. Handle Hardcoded Admin
        if username == "admin":
            return {"ldap_uid": "admin", "full_name": "Administrateur Local", "role": UserRole.SUPER_ADMIN}

        # 2. Check in Local DB
        statement = select(User).where(User.ldap_uid == username)
        user = session.exec(statement).first()
        
        if user:
            return user
            
        # 3. If authenticated but not in DB, return minimal info (Guest)
        return {"ldap_uid": username, "full_name": username, "role": UserRole.GUEST}

    except JWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")

def require_staff(current_user: any = Depends(get_current_user)):
    """
    Restrict access to PROFESSOR, ADMIN or SUPER_ADMIN.
    """
    # Si c'est un dictionnaire (admin local ou user non-synchro)
    role = current_user["role"] if isinstance(current_user, dict) else current_user.role
    
    allowed_roles = [UserRole.SUPER_ADMIN, UserRole.ADMIN, UserRole.PROFESSOR, 
                     UserRole.PROF_RESP_PARCOURS, UserRole.PROF_RESP_SAE]
    
    if role not in allowed_roles:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, 
            detail="Accès réservé au personnel enseignant et administratif."
        )
    return current_user
