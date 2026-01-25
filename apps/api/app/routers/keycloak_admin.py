from fastapi import APIRouter, Depends, HTTPException
from typing import List
from ..dependencies import require_staff
from ..services.keycloak_service import list_local_users, create_local_user, delete_local_user
from pydantic import BaseModel

router = APIRouter(tags=["Keycloak Admin"])

class UserCreate(BaseModel):
    username: str
    email: str
    first_name: str
    last_name: str
    password: str

class PasswordReset(BaseModel):
    password: str

@router.get("/keycloak/users")
def get_keycloak_users(q: str = None, current_user: any = Depends(require_staff)):
    return list_local_users(search_query=q)

@router.post("/keycloak/users")
def add_keycloak_user(user: UserCreate, current_user: any = Depends(require_staff)):
    return create_local_user(user.username, user.email, user.first_name, user.last_name, user.password)

@router.delete("/keycloak/users/{user_id}")
def remove_keycloak_user(user_id: str, current_user: any = Depends(require_staff)):
    if delete_local_user(user_id):
        return {"status": "deleted"}
    raise HTTPException(status_code=400, detail="Delete failed")

@router.put("/keycloak/users/{user_id}/reset-password")
def reset_kc_password(user_id: str, data: PasswordReset, current_user: any = Depends(require_staff)):
    if reset_user_password(user_id, data.password):
        return {"status": "success"}
    raise HTTPException(status_code=400, detail="Reset failed")
