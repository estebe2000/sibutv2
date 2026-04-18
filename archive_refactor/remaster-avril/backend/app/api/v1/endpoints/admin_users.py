from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select
from typing import List, Dict, Any
from app.models.models import User, UserRole
from app.main import engine
from app.services.keycloak_service import search_users_in_keycloak

router = APIRouter()

def get_session():
    with Session(engine) as session:
        yield session

@router.get("/search")
async def search_all_users(q: str):
    """Recherche globale via Keycloak (LDAP + Local)"""
    if not q or len(q) < 3: return []
    try:
        users = await search_users_in_keycloak(q)
        # On peut filtrer ici pour ne renvoyer que les profs si Keycloak le permet
        return users
    except Exception as e:
        print(f"Keycloak Search Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("")
async def create_local_user(data: Dict[str, Any], session: Session = Depends(get_session)):
    """Crée un utilisateur local dans le Hub"""
    existing = session.exec(select(User).where(User.ldap_uid == data["username"])).first()
    if existing: raise HTTPException(status_code=400, detail="Utilisateur déjà existant")
    
    new_user = User(
        ldap_uid=data["username"],
        full_name=data["full_name"],
        email=data["email"],
        role=UserRole.PROFESSOR # Par défaut pour les locaux de cette vue
    )
    session.add(new_user); session.commit()
    return {"status": "success"}

@router.delete("/{uid}")
async def delete_user(uid: str, session: Session = Depends(get_session)):
    user = session.exec(select(User).where(User.ldap_uid == uid)).first()
    if not user: raise HTTPException(status_code=404, detail="Non trouvé")
    session.delete(user); session.commit()
    return {"status": "deleted"}
