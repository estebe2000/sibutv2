import httpx
import os
from app.core.config import settings

async def get_admin_token():
    """Récupère un token d'administration Keycloak"""
    # On tente d'utiliser les credentials admin définis dans le .env
    url = f"{settings.KEYCLOAK_URL}/realms/master/protocol/openid-connect/token"
    data = {
        "grant_type": "password",
        "client_id": "admin-cli",
        "username": os.getenv("KEYCLOAK_ADMIN", "admin"),
        "password": os.getenv("KEYCLOAK_ADMIN_PASSWORD", "Rangetachambre76*") # Utilisation du password connu du projet
    }
    async with httpx.AsyncClient(timeout=10.0) as client:
        try:
            resp = await client.post(url, data=data)
            resp.raise_for_status()
            return resp.json()["access_token"]
        except:
            # Fallback sur le realm spécifique si master échoue
            url = f"{settings.KEYCLOAK_URL}/realms/{settings.KEYCLOAK_REALM}/protocol/openid-connect/token"
            resp = await client.post(url, data=data)
            resp.raise_for_status()
            return resp.json()["access_token"]

async def search_users_in_keycloak(query: str):
    """Cherche des utilisateurs dans Keycloak (inclut le LDAP fédéré)"""
    token = await get_admin_token()
    url = f"{settings.KEYCLOAK_URL}/admin/realms/{settings.KEYCLOAK_REALM}/users"
    headers = {"Authorization": f"Bearer {token}"}
    
    # Stratégie radicale : On récupère les 100 premiers utilisateurs du realm
    # et on filtre nous-mêmes par email ou username
    params = {"max": 100}
    
    async with httpx.AsyncClient(timeout=10.0) as client:
        try:
            resp = await client.get(url, headers=headers, params=params)
            if resp.status_code == 200:
                all_users = resp.json()
                results = []
                for u in all_users:
                    # Filtrage manuel par la query (ex: @univ-lehavre.fr)
                    match = False
                    email = u.get("email", "")
                    username = u.get("username", "")
                    
                    if query.lower() in email.lower() or query.lower() in username.lower():
                        match = True
                        
                    if match:
                        results.append({
                            "username": username,
                            "full_name": f"{u.get('firstName', '')} {u.get('lastName', '')}".strip() or username,
                            "email": email,
                            "id": u.get("id")
                        })
                return results
        except Exception as e:
            print(f"Keycloak Total Fetch Error: {e}")
            return []
    return []
