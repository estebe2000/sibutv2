import requests
import os
from fastapi import HTTPException

KC_URL = os.getenv("KEYCLOAK_URL", "http://but_tc_keycloak:8080")
KC_REALM = os.getenv("KEYCLOAK_REALM", "but-tc")
KC_ADMIN_USER = os.getenv("KEYCLOAK_ADMIN", "admin")
KC_ADMIN_PASS = os.getenv("KEYCLOAK_ADMIN_PASSWORD", "Rangetachambre76*")

def get_admin_token():
    """Récupère un token d'administration pour Keycloak."""
    url = f"{KC_URL}/realms/master/protocol/openid-connect/token"
    data = {
        "client_id": "admin-cli",
        "username": KC_ADMIN_USER,
        "password": KC_ADMIN_PASS,
        "grant_type": "password"
    }
    try:
        response = requests.post(url, data=data, timeout=10)
        response.raise_for_status()
        return response.json()["access_token"]
    except Exception as e:
        print(f"Keycloak Admin Token Error: {e}")
        return None

def list_local_users(search_query: str = None):
    """Liste ou recherche les utilisateurs de Keycloak."""
    token = get_admin_token()
    if not token: return []
    
    headers = {"Authorization": f"Bearer {token}"}
    
    # 1. Si on a une recherche, on utilise l'API de recherche globale
    if search_query:
        url = f"{KC_URL}/admin/realms/{KC_REALM}/users?max=100&search={search_query.strip()}"
        try:
            response = requests.get(url, headers=headers, timeout=10)
            return response.json()
        except Exception as e:
            print(f"Keycloak Search Error: {e}")
            return []

    # 2. Par défaut, on récupère un grand nombre pour être sûr de trouver tous les locaux
    # On monte à 10000 car les environnements universitaires ont beaucoup d'utilisateurs LDAP
    url = f"{KC_URL}/admin/realms/{KC_REALM}/users?max=10000"
    try:
        response = requests.get(url, headers=headers, timeout=15)
        all_users = response.json()
        
        # Filtrage strict : on veut uniquement ceux qui n'ont AUCUN lien de fédération
        # et on s'assure de ne pas rater intervenant.exterieur
        locals = [u for u in all_users if u.get("federationLink") is None]
        ldaps = [u for u in all_users if u.get("federationLink") is not None]
        
        # On renvoie TOUS les locaux trouvés (très important pour l'utilisateur)
        # et on complète avec un petit échantillon de LDAP pour ne pas saturer l'UI
        return locals + ldaps[:10]
    except Exception as e:
        print(f"Keycloak List Users Error: {e}")
        return []

def create_local_user(username, email, first_name, last_name, password):
    """Crée un utilisateur local dans Keycloak."""
    token = get_admin_token()
    if not token: raise HTTPException(status_code=500, detail="Could not connect to Keycloak")
    
    url = f"{KC_URL}/admin/realms/{KC_REALM}/users"
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    
    user_data = {
        "username": username,
        "email": email,
        "firstName": first_name,
        "lastName": last_name,
        "enabled": True,
        "credentials": [{"type": "password", "value": password, "temporary": False}]
    }
    
    response = requests.post(url, json=user_data, headers=headers, timeout=10)
    if response.status_code == 201:
        return True
    else:
        raise HTTPException(status_code=response.status_code, detail=response.text)

def delete_local_user(user_id):
    """Supprime un utilisateur dans Keycloak."""
    token = get_admin_token()
    if not token: return False
    
    url = f"{KC_URL}/admin/realms/{KC_REALM}/users/{user_id}"
    headers = {"Authorization": f"Bearer {token}"}
    
    response = requests.delete(url, headers=headers, timeout=10)
    return response.status_code == 204
