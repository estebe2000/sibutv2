from fastapi import APIRouter, Request, Depends, HTTPException
import httpx, psycopg2
from sqlmodel import Session, select
from app.core.security import admin_only, prof_or_admin, engine
from app.core.config import settings
from app.models.models import User, UserRole, Promotion, Group

router = APIRouter(prefix="/admin", tags=["admin"])

@router.post("/dispatch/auto-sync", dependencies=[Depends(admin_only)])
async def auto_sync_scodoc():
    print("🚀 DÉMARRAGE SYNCHRO SCODOC...")
    try:
        async with httpx.AsyncClient(timeout=60.0) as client:
            print("📡 Appel API ScoDoc...")
            h_resp = await client.get("http://host.docker.internal:8092/api/hierarchie")
            scodoc_data = h_resp.json()
            
            stats = {"users": 0, "groups": 0, "resources_updated": 0}
            
            with Session(engine) as session:
                print("🔑 Connexion Keycloak DB...")
                kc_conn = psycopg2.connect(host=settings.KC_DB_HOST, database=settings.KC_DB_NAME, user=settings.KC_DB_USER, password=settings.KC_DB_PASS)
                kc_cur = kc_conn.cursor()
                
                for f_name, types in scodoc_data.items():
                    print(f"📁 Traitement Formation: {f_name}")
                    year = 2026 if "2026" in f_name or "BUT1" in f_name else 2025 if "2025" in f_name or "BUT2" in f_name else 2024
                    promo = session.exec(select(Promotion).where(Promotion.entry_year == year)).first()
                    if not promo: continue
                    
                    for t_name, groups in types.items():
                        for g_name, students in groups.items():
                            group = session.exec(select(Group).where(Group.name == g_name, Group.promotion_id == promo.id)).first()
                            if not group:
                                print(f"➕ Création Groupe: {g_name}")
                                group = Group(name=g_name, promotion_id=promo.id, year=year, academic_year="2025-2026", formation_type=t_name)
                                session.add(group); session.commit(); session.refresh(group)
                                stats["groups"] += 1
                            
                            print(f"👥 Sync {len(students)} étudiants pour {g_name}...")
                            for s in students:
                                email = s.get("email", "").lower()
                                if email:
                                    kc_cur.execute("SELECT username FROM user_entity WHERE LOWER(email) = %s LIMIT 1", (email,))
                                else:
                                    kc_cur.execute("SELECT username FROM user_entity WHERE LOWER(first_name) = %s AND LOWER(last_name) = %s LIMIT 1", (s.get("prenom", "").lower(), s.get("nom", "").lower()))
                                
                                kc_row = kc_cur.fetchone()
                                uid = kc_row[0] if kc_row else f"nip_{s.get('nip')}"

                                user = session.exec(select(User).where(User.ldap_uid == uid)).first()
                                if not user:
                                    user = User(
                                        ldap_uid=uid, nip=str(s.get("nip")), 
                                        full_name=f"{s.get('prenom')} {s.get('nom')}", 
                                        email=email or f"{uid}@univ-lehavre.fr", 
                                        role=UserRole.STUDENT, promotion_id=promo.id, group_id=group.id
                                    )
                                    session.add(user)
                                    stats["users"] += 1
                                else:
                                    user.group_id = group.id; user.promotion_id = promo.id; user.nip = str(s.get("nip")); session.add(user)
                
                print("💾 Validation des changements (Commit)...")
                session.commit(); kc_cur.close(); kc_conn.close()
                print("✅ SYNCHRO TERMINÉE.")
        return {"status": "success", "stats": stats}
    except Exception as e: 
        print(f"❌ ERREUR SYNCHRO: {e}")
        return {"status": "error", "detail": str(e)}

@router.get("/users/search", dependencies=[Depends(prof_or_admin)])
@router.get("/users/professors", dependencies=[Depends(prof_or_admin)])
async def admin_users_search(q: str = ""):
    results = []
    with Session(engine) as session:
        locals = session.exec(select(User).where(User.full_name.ilike(f"%{q}%") | User.ldap_uid.ilike(f"%{q}%")).limit(10)).all()
        for u in locals: results.append({"ldap_uid": u.ldap_uid, "full_name": u.full_name, "id": u.id})
    try:
        conn = psycopg2.connect(host=settings.KC_DB_HOST, database=settings.KC_DB_NAME, user=settings.KC_DB_USER, password=settings.KC_DB_PASS)
        cur = conn.cursor(); cur.execute("SELECT username, first_name, last_name, email FROM user_entity WHERE (username ILIKE %s OR first_name ILIKE %s OR last_name ILIKE %s) LIMIT 10", (f"%{q}%", f"%{q}%", f"%{q}%"))
        for row in cur.fetchall():
            if not any(r["ldap_uid"] == row[0] for r in results):
                results.append({"ldap_uid": row[0], "full_name": f"{row[1]} {row[2]}".strip() or row[0], "email": row[3], "source": "keycloak"})
        cur.close(); conn.close()
    except: pass
    return results

@router.put("/users/{uid}/roles", dependencies=[Depends(admin_only)])
async def update_user_roles(uid: str, roles: list[str]):
    import json
    with Session(engine) as session:
        user = session.exec(select(User).where(User.ldap_uid == uid)).first()
        if user and roles:
            user.role = UserRole(roles[0])
            user.roles_json = json.dumps(roles)
            session.add(user)
            session.commit()
            return {"status": "success"}
    raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
