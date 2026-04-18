from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select
import httpx
from typing import List, Dict, Any
from app.models.models import User, Group, Promotion, UserRole
from app.core.config import settings
# On va utiliser une méthode plus simple pour la session
from app.main import engine 

def get_session():
    with Session(engine) as session:
        yield session

router = APIRouter()

SCODOC_RELAY_URL = "http://host.docker.internal:8092" # URL stable entre conteneurs

@router.get("/preview")
async def get_scodoc_preview():
    """Mode Lecture : Affiche tout ce qui est disponible dans ScoDoc (Étudiants + Ressources)"""
    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            # 1. Récupération de la hiérarchie étudiants
            h_resp = await client.get(f"{SCODOC_RELAY_URL}/api/hierarchie")
            # 2. Récupération des ressources (SAÉ/Modules)
            r_resp = await client.get(f"{SCODOC_RELAY_URL}/api/ressources")
            
            return {
                "hierarchy": h_resp.json() if h_resp.status_code == 200 else {},
                "resources": r_resp.json() if r_resp.status_code == 200 else []
            }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur lors de la récupération ScoDoc : {str(e)}")

@router.post("/auto-sync")
async def auto_sync_scodoc(session: Session = Depends(get_session)):
    """Synchronisation automatique totale : Importe tout et range par défaut"""
    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            scodoc_data = (await client.get(f"{SCODOC_RELAY_URL}/api/hierarchie")).json()

        stats = {"users": 0, "groups": 0}
        current_year = 2026

        for level, types in scodoc_data.items():
            # 1. Calcul de la promo cible (B1=26, B2=25, B3=24)
            level_num = int(level.replace("BUT", "").strip())
            promo_entry_year = current_year - level_num + 1
            promo_name = f"Promo {str(promo_entry_year)[2:]}"
            
            promo = session.exec(select(Promotion).where(Promotion.entry_year == promo_entry_year)).first()
            if not promo:
                promo = Promotion(name=promo_name, entry_year=promo_entry_year)
                session.add(promo); session.commit(); session.refresh(promo)

            for f_type, groups in types.items():
                for sc_name, students in groups.items():
                    # 2. Nommage automatique
                    unique_name = f"[{level}] {sc_name} ({f_type})"
                    
                    group = session.exec(select(Group).where(Group.name == unique_name, Group.promotion_id == promo.id)).first()
                    if not group:
                        group = Group(
                            name=unique_name, promotion_id=promo.id, year=level_num,
                            formation_type=f_type, pathway=students[0]["parcours"] if students else "N/A"
                        )
                        session.add(group); session.commit(); session.refresh(group)
                        stats["groups"] += 1

                    # 3. Import des étudiants
                    for s in students:
                        user = session.exec(select(User).where(User.nip == s["nip"])).first()
                        if not user:
                            user = User(
                                nip=s["nip"], ldap_uid=s["nip"], email=s["email"],
                                full_name=f"{s['nom']} {s['prenom']}", role=UserRole.STUDENT,
                                promotion_id=promo.id, group_id=group.id
                            )
                            session.add(user); stats["users"] += 1
                        else:
                            user.group_id = group.id; user.promotion_id = promo.id
                            session.add(user)
        
        session.commit()
        return {"status": "success", "stats": stats}
    except Exception as e:
        session.rollback()
        raise HTTPException(status_code=500, detail=str(e))

@router.patch("/groups/{group_id}")
async def rename_group(group_id: int, data: Dict[str, str], session: Session = Depends(get_session)):
    """Renomme un groupe importé"""
    group = session.get(Group, group_id)
    if not group: raise HTTPException(status_code=404, detail="Groupe non trouvé")
    group.name = data.get("name", group.name)
    session.add(group); session.commit(); session.refresh(group)
    return group

@router.delete("/groups/{group_id}")
async def delete_group(group_id: int, session: Session = Depends(get_session)):
    """Supprime un groupe et désassigne les étudiants"""
    group = session.get(Group, group_id)
    if not group: raise HTTPException(status_code=404, detail="Groupe non trouvé")
    # Désassignation des utilisateurs (pour ne pas supprimer les comptes)
    for user in group.users:
        user.group_id = None
        session.add(user)
    session.delete(group)
    session.commit()
    return {"status": "deleted"}
