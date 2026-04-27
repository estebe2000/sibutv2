from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import OAuth2AuthorizationCodeBearer
from typing import Optional, List
from pydantic import BaseModel

router = APIRouter()

oauth2_scheme = OAuth2AuthorizationCodeBearer(
    authorizationUrl="http://localhost:8080/realms/but-tc/protocol/openid-connect/auth",
    tokenUrl="http://localhost:8080/realms/but-tc/protocol/openid-connect/token"
)

class UserProfile(BaseModel):
    username: str
    full_name: str
    role: str # STUDENT, PROFESSOR, ADMIN

@router.get("/me", response_model=UserProfile)
async def get_me(token: str = Depends(oauth2_scheme)):
    # Simulation du profil basé sur le token Keycloak (Mode dégradé)
    # Dans une version finale, on cherchera dans la DB.
    
    # Ici on simule pour le test
    import jwt
    decoded = jwt.decode(token, options={"verify_signature": False})
    username = decoded.get("preferred_username", "unknown")
    
    role = "STUDENT"
    if "admin" in decoded.get("realm_access", {}).get("roles", []):
        role = "ADMIN"
    elif "professor" in decoded.get("realm_access", {}).get("roles", []):
        role = "PROFESSOR"
    elif "admin-iutlh" in username:
        role = "ADMIN"
    elif "prof-iutlh" in username:
        role = "PROFESSOR"

    return {
        "username": username,
        "full_name": decoded.get("name", username),
        "role": role
    }

@router.get("/test")
async def auth_test(token: str = Depends(oauth2_scheme)):
    return {"message": "connection ok", "user": "admin"}
