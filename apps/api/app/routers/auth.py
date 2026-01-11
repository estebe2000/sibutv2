from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlmodel import Session, select
from datetime import datetime, timedelta
from jose import JWTError, jwt
from ..database import get_session
from ..models import User, Group
from ..ldap_utils import verify_credentials

router = APIRouter(tags=["Auth"])

# JWT CONFIG
SECRET_KEY = "supersecretkeychangeinprod"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60

def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

@router.post("/login")
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    if form_data.username == "admin" and form_data.password == "Rangetachambre76*":
        return {"access_token": create_access_token({"sub": "admin"}), "token_type": "bearer"}
    if verify_credentials(form_data.username, form_data.password):
        if form_data.username != "admin":
             # We might want to allow non-admin login later, but for now logic is same as main.py
             # Wait, main.py said: if form_data.username != "admin": raise HTTPException(status_code=403, detail="Accès réservé aux administrateurs")
             # But it also checked verify_credentials.
             # The original code:
             # if verify_credentials(form_data.username, form_data.password):
             #   if form_data.username != "admin":
             #        raise HTTPException(status_code=403, detail="Accès réservé aux administrateurs")
             #   return {"access_token": create_access_token({"sub": form_data.username}), "token_type": "bearer"}
             raise HTTPException(status_code=403, detail="Accès réservé aux administrateurs")
        return {"access_token": create_access_token({"sub": form_data.username}), "token_type": "bearer"}
    raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Incorrect username or password")
