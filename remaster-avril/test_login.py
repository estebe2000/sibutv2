import requests
import time
import sys

# Configuration
KEYCLOAK_URL = "http://localhost:8080"
REALM = "but-tc"
CLIENT_ID = "skills-hub-app"
API_URL = "http://localhost:8000/api/v1"

USERNAME = "pytels"
PASSWORD = "Monpetitponey76**"

def wait_for_service(url, name, timeout=60):
    """Attendre qu'un service soit disponible"""
    start_time = time.time()
    print(f"[*] Attente du service {name} ({url})...")
    while time.time() - start_time < timeout:
        try:
            response = requests.get(url, timeout=2)
            if response.status_code < 500:
                print(f"[+] {name} est en ligne !")
                return True
        except requests.exceptions.RequestException:
            pass
        time.sleep(2)
    print(f"[!] Erreur: Timeout lors de l'attente de {name}")
    return False

def test_connection():
    # 1. Obtenir un token de Keycloak
    token_url = f"{KEYCLOAK_URL}/realms/{REALM}/protocol/openid-connect/token"
    
    payload = {
        'grant_type': 'password',
        'client_id': CLIENT_ID,
        'username': USERNAME,
        'password': PASSWORD,
        'scope': 'openid profile email'
    }
    
    print(f"[*] Tentative de connexion Keycloak pour '{USERNAME}'...")
    try:
        response = requests.post(token_url, data=payload)
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
    print(f"[*] Appel de l'endpoint de test API: {API_URL}/auth/test")
    headers = {
        'Authorization': f'Bearer {access_token}'
    }
    
    try:
        api_response = requests.get(f"{API_URL}/auth/test", headers=headers)
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
    
    # On vérifie d'abord si les services sont lancés (optionnel mais utile)
    # wait_for_service(f"{KEYCLOAK_URL}/health", "Keycloak")
    # wait_for_service(f"{API_URL}/health", "API")
    
    if test_connection():
        print("\n[SUCCESS] La chaîne d'authentification complète est fonctionnelle !")
        sys.exit(0)
    else:
        print("\n[FAILURE] Le test a échoué.")
        sys.exit(1)
