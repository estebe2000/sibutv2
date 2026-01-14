from fastapi import APIRouter, Depends, HTTPException, status, Form
from fastapi.security import OAuth2PasswordRequestForm
from sqlmodel import Session, select
from datetime import datetime, timedelta
from jose import JWTError, jwt
from ..database import get_session
from ..models import User, Group
from ..services.ldap_service import verify_credentials

import requests
import os

router = APIRouter(tags=["Auth"])

# KEYCLOAK CONFIG
KC_URL = os.getenv("KEYCLOAK_URL", "http://keycloak:8080/auth")
KC_REALM = os.getenv("KEYCLOAK_REALM", "but-tc")
KC_CLIENT_ID = os.getenv("KEYCLOAK_CLIENT_ID", "skills-hub-app")
KC_CLIENT_SECRET = os.getenv("KEYCLOAK_CLIENT_SECRET", "")

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
    print(f"Login attempt for user: {form_data.username}", flush=True)
    # 1. Check local admin override
    if form_data.username == "admin" and form_data.password == "Rangetachambre76*":
        return {"access_token": create_access_token({"sub": "admin"}), "token_type": "bearer"}
    
    # 2. Try to authenticate against Keycloak
    token_url = f"{KC_URL}/realms/{KC_REALM}/protocol/openid-connect/token"
    print(f"Requesting token from Keycloak: {token_url}", flush=True)
    data = {
        "grant_type": "password",
        "client_id": KC_CLIENT_ID,
        "client_secret": KC_CLIENT_SECRET,
        "username": form_data.username,
        "password": form_data.password,
        "scope": "openid"
    }
    
    try:
        response = requests.post(token_url, data=data, timeout=10)
        print(f"Keycloak response code: {response.status_code}", flush=True)
        if response.status_code == 200:
            return {"access_token": create_access_token({"sub": form_data.username}), "token_type": "bearer"}
        else:
            print(f"Keycloak Auth Failed: {response.text}", flush=True)
    except Exception as e:
        print(f"Keycloak Connection Error: {e}", flush=True)
    
    # 3. Fallback to LDAP direct (optional, but good for transition)
    if verify_credentials(form_data.username, form_data.password):
        return {"access_token": create_access_token({"sub": form_data.username}), "token_type": "bearer"}
    
    raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Identifiants incorrects")

@router.post("/auth/callback")
async def auth_callback(code: str = Form(...), redirect_uri: str = Form(...)):
    """
    Exchange authorization code for access token.
    """
    token_url = f"{KC_URL}/realms/{KC_REALM}/protocol/openid-connect/token"
    data = {
        "grant_type": "authorization_code",
        "client_id": KC_CLIENT_ID,
        "client_secret": KC_CLIENT_SECRET,
        "code": code,
        "redirect_uri": redirect_uri
    }
    
    try:
        response = requests.post(token_url, data=data, timeout=10)
        if response.status_code == 200:
            token_data = response.json()
            # Extract username from id_token or access_token
            payload = jwt.get_unverified_claims(token_data['access_token'])
            username = payload.get("preferred_username", payload.get("sub"))
            
            # Emit our local token for the Skills Hub compatibility
            return {
                "access_token": create_access_token({"sub": username}),
                "username": username,
                "token_type": "bearer"
            }
        else:
            print(f"Keycloak Code Exchange Failed: {response.text}", flush=True)
            raise HTTPException(status_code=400, detail="Code exchange failed")
    except Exception as e:
        print(f"Keycloak Callback Error: {e}", flush=True)
        raise HTTPException(status_code=500, detail=str(e))
