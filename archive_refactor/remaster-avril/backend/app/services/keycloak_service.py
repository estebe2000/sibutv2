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
    params = {"search": query, "max": 20}
    
    async with httpx.AsyncClient(timeout=10.0) as client:
        resp = await client.get(url, headers=headers, params=params)
        resp.raise_for_status()
        users = resp.json()
        
        # Formatage pour le Hub
        results = []
        for u in users:
            # Un étudiant a souvent un email @etu. ou un pattern spécifique
            # On peut aussi filtrer par groupe Keycloak si nécessaire
            results.append({
                "username": u.get("username"),
                "full_name": f"{u.get('firstName', '')} {u.get('lastName', '')}".strip() or u.get("username"),
                "email": u.get("email"),
                "is_ldap": "federationLink" in u or "univ-lehavre" in u.get("email", ""),
                "id": u.get("id")
            })
        return results
