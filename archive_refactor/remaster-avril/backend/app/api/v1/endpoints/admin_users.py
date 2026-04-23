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

@router.get("/professors")
async def list_professors(q: str = None, session: Session = Depends(get_session)):
    """Liste tous les professeurs (filtre par email univ-lehavre.fr + base locale)"""
    try:
        # 1. Recherche Keycloak (si q est fourni, on cherche q, sinon le domaine)
        search_query = q if q and len(q) >= 3 else "univ-lehavre.fr"
        profs = await search_users_in_keycloak(search_query)
        
        # 2. On ajoute les profs de la base locale
        statement = select(User).where(User.role != UserRole.STUDENT)
        if q:
            statement = statement.where(
                (User.full_name.ilike(f"%{q}%")) | (User.ldap_uid.ilike(f"%{q}%")) | (User.email.ilike(f"%{q}%"))
            )
        
        db_users = session.exec(statement).all()
        for u in db_users:
            if not any(p['username'] == u.ldap_uid for p in profs):
                profs.append({
                    "username": u.ldap_uid,
                    "full_name": u.full_name,
                    "email": u.email,
                    "id": u.id
                })
        
        return profs
    except Exception as e:
        print(f"Professor List Error: {e}")
        return []

@router.get("/search")
async def search_all_users(q: str, session: Session = Depends(get_session)):
    """Recherche globale via Keycloak ET base locale"""
    if not q or len(q) < 3: return []
    try:
        # 1. Recherche en base locale (Étudiants synchronisés de ScoDoc)
        db_users = session.exec(select(User).where(
            (User.full_name.ilike(f"%{q}%")) | 
            (User.ldap_uid.ilike(f"%{q}%")) | 
            (User.email.ilike(f"%{q}%"))
        )).all()
        
        results = [{
            "id": u.id, 
            "username": u.ldap_uid, 
            "full_name": u.full_name, 
            "email": u.email, 
            "role": u.role,
            "group_id": u.group_id,
            "source": "local"
        } for u in db_users]
        
        # 2. Recherche Keycloak (LDAP de l'université)
        try:
            keycloak_users = await search_users_in_keycloak(q)
            for ku in keycloak_users:
                if not any(r['username'] == ku['username'] for r in results):
                    ku["source"] = "keycloak"
                    results.append(ku)
        except: pass # Keycloak peut être indisponible
                
        return results
    except Exception as e:
        print(f"Global Search Error: {e}")
        return []

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

@router.patch("/{uid}/roles")
async def update_user_roles(uid: str, roles: List[str], session: Session = Depends(get_session)):
    user = session.exec(select(User).where(User.ldap_uid == uid)).first()
    if not user: raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
    
    import json
    user.roles_json = json.dumps(roles)
    
    # On met à jour le rôle principal par le premier de la liste pour la compatibilité descendante
    if roles:
        user.role = roles[0]
        
    session.add(user); session.commit()
    return {"status": "success", "roles": roles}

@router.delete("/{uid}")
async def delete_user(uid: str, session: Session = Depends(get_session)):
    user = session.exec(select(User).where(User.ldap_uid == uid)).first()
    if not user: raise HTTPException(status_code=404, detail="Non trouvé")
    session.delete(user); session.commit()
    return {"status": "deleted"}
