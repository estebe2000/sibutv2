import requests
import time
import sys

# Configuration
# En local sur Mac, on passe par l'Ingress (port 80) 
# et on utilise les headers Host pour le routage Nginx
INGRESS_URL = "http://localhost:80"
DOMAIN = "educ-ai.fr"
REALM = "but-tc"
CLIENT_ID = "skills-hub-app"

USERNAME = "pytels"
PASSWORD = "Monpetitponey76**"

def test_connection():
    # 1. Obtenir un token de Keycloak
    token_url = f"{INGRESS_URL}/realms/{REALM}/protocol/openid-connect/token"
    auth_host = f"auth.{DOMAIN}"
    
    payload = {
        'grant_type': 'password',
        'client_id': CLIENT_ID,
        'username': USERNAME,
        'password': PASSWORD,
        'scope': 'openid profile email'
    }
    
    print(f"[*] Tentative de connexion Keycloak ({auth_host}) pour '{USERNAME}'...")
    try:
        response = requests.post(token_url, data=payload, headers={"Host": auth_host}, timeout=10)
        if response.status_code != 200:
            print(f"[!] Échec de l'authentification: {response.status_code}")
            print(f"Détails: {response.text}")
            return False
        
        token_data = response.json()
        access_token = token_data.get("access_token")
        print("[+] Token JWT récupéré avec succès !")
        
    except Exception as e:
        print(f"[!] Erreur lors de l'appel Keycloak: {e}")
        return False

    # 2. Appeler l'API avec le token
    api_host = f"hub.{DOMAIN}"
    api_url = f"{INGRESS_URL}/api/v1/auth/test"
    print(f"[*] Appel de l'endpoint de test API ({api_host}): {api_url}")
    headers = {
        'Authorization': f'Bearer {access_token}',
        'Host': api_host
    }
    
    try:
        api_response = requests.get(api_url, headers=headers, timeout=10)
        if api_response.status_code == 200:
            result = api_response.json()
            print("\n" + "="*40)
            print(f"RÉSULTAT: {result.get('message', '??')}")
            print(f"UTILISATEUR: {result.get('user', '??')}")
            print("="*40)
            return True
        else:
            print(f"[!] L'API a répondu avec une erreur: {api_response.status_code}")
            print(f"Détails: {api_response.text}")
            return False
            
    except Exception as e:
        print(f"[!] Erreur lors de l'appel API: {e}")
        return False

if __name__ == "__main__":
    print("=== TEST DE CONNEXION SKILLS HUB REMASTER ===\n")
    
    if test_connection():
        print("\n[SUCCESS] La chaîne d'authentification complète est fonctionnelle !")
        sys.exit(0)
    else:
        print("\n[FAILURE] Le test a échoué.")
        sys.exit(1)
