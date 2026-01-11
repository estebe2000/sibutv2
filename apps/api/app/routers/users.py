from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select
from typing import List
from ..database import get_session
from ..models import Group, User, UserRole
from ..ldap_utils import get_ldap_users
from ..dependencies import get_current_user
import os

router = APIRouter(tags=["Users"])

# --- GROUPS ---
@router.get("/groups", response_model=List[Group])
def list_groups(session: Session = Depends(get_session), current_user: str = Depends(get_current_user)):
    return session.exec(select(Group)).all()

@router.post("/groups", response_model=Group)
def create_group(group: Group, session: Session = Depends(get_session), current_user: str = Depends(get_current_user)):
    session.add(group); session.commit(); session.refresh(group)
    return group

@router.patch("/groups/{group_id}", response_model=Group)
def update_group(group_id: int, group_data: Group, session: Session = Depends(get_session), current_user: str = Depends(get_current_user)):
    group = session.get(Group, group_id)
    if not group: raise HTTPException(status_code=404, detail="Group not found")
    group_data_dict = group_data.model_dump(exclude_unset=True)
    if 'id' in group_data_dict: del group_data_dict['id']
    for key, value in group_data_dict.items(): setattr(group, key, value)
    session.add(group); session.commit(); session.refresh(group)
    return group

@router.delete("/groups/{group_id}")
def delete_group(group_id: int, session: Session = Depends(get_session), current_user: str = Depends(get_current_user)):
    group = session.get(Group, group_id)
    if not group: raise HTTPException(status_code=404, detail="Group not found")
    users = session.exec(select(User).where(User.group_id == group_id)).all()
    for user in users:
        user.group_id = None
        user.role = UserRole.GUEST
        session.add(user)
    session.delete(group); session.commit()
    return {"status": "success"}

# --- USERS & DISPATCHING ---
@router.get("/ldap-users")
def list_ldap_raw(current_user: str = Depends(get_current_user)):
    return get_ldap_users()

@router.get("/users", response_model=List[User])
def list_assigned_users(session: Session = Depends(get_session), current_user: str = Depends(get_current_user)):
    return session.exec(select(User)).all()

@router.post("/users/assign")
def assign_user(user_data: User, session: Session = Depends(get_session), current_user: str = Depends(get_current_user)):
    existing = session.exec(select(User).where(User.ldap_uid == user_data.ldap_uid)).first()
    group = session.get(Group, user_data.group_id) if user_data.group_id else None
    role = user_data.role
    if group and group.name == "Enseignants": role = UserRole.PROFESSOR
    if existing:
        existing.role = role
        existing.group_id = user_data.group_id
        session.add(existing)
    else:
        user_data.role = role
        session.add(user_data)
    session.commit()
    return {"status": "success"}

@router.post("/users/unassign")
def unassign_user(ldap_uid: str, session: Session = Depends(get_session), current_user: str = Depends(get_current_user)):
    user = session.exec(select(User).where(User.ldap_uid == ldap_uid)).first()
    if user:
        user.group_id = None
        user.role = UserRole.GUEST
        session.add(user); session.commit()
        return {"status": "success"}
    raise HTTPException(status_code=404, detail="User not found")

@router.post("/users/{ldap_uid}/quota")
def set_user_quota(ldap_uid: str, quota: str = "100 GB", session: Session = Depends(get_session), current_user: str = Depends(get_current_user)):
    import requests
    from requests.auth import HTTPBasicAuth

    nc_url = os.getenv("NEXTCLOUD_URL", "http://nextcloud")
    nc_admin = os.getenv("NEXTCLOUD_ADMIN", "admin")
    nc_pass = os.getenv("NEXTCLOUD_PASS", "Rangetachambre76*")

    url = f"{nc_url}/ocs/v1.php/cloud/users/{ldap_uid}"
    headers = {"OCS-APIRequest": "true"}
    data = {"key": "quota", "value": quota}

    try:
        response = requests.put(url, data=data, headers=headers, auth=HTTPBasicAuth(nc_admin, nc_pass))
        if response.status_code == 200:
            return {"status": "success"}
        else:
            raise HTTPException(status_code=response.status_code, detail=f"Nextcloud API error: {response.text}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
