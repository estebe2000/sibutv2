import requests
from bs4 import BeautifulSoup
import urllib3
import os

# Désactiver les avertissements SSL
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# === CONFIGURATION ===
BASE_URL = "https://scodoc.univ-lehavre.fr"
LOGIN_URL = f"{BASE_URL}/auth/login"
USERNAME = "pytels"
PASSWORD = "27041978"

def test_web_login():
    session = requests.Session()
    session.verify = False # Ignorer SSL
    
    print(f"🔍 Accès à la page de login : {LOGIN_URL}")
    
    # 1. Get login page to extract CSRF token
    try:
        response = session.get(LOGIN_URL)
        response.raise_for_status()
        
        soup = BeautifulSoup(response.text, 'html.parser')
        csrf_token = soup.find('input', {'id': 'csrf_token'})['value']
        print(f"✅ CSRF Token trouvé : {csrf_token[:10]}...")
        
        # 2. Perform Login
        payload = {
            "csrf_token": csrf_token,
            "user_name": USERNAME,
            "password": PASSWORD,
            "submit": "Suivant"
        }
        
        print("🚀 Tentative de connexion...")
        login_resp = session.post(LOGIN_URL, data=payload, allow_redirects=True)
        
        if "Déconnexion" in login_resp.text or "Scolarité" in login_resp.text:
            print("🎉 CONNEXION RÉUSSIE !")
            
            # 3. Test access to TC Department
            tc_url = f"{BASE_URL}/ScoDoc/TC/Scolarite/"
            print(f"📂 Accès au département TC : {tc_url}")
            tc_resp = session.get(tc_url)
            
            if tc_resp.status_code == 200:
                print("✅ Accès au département TC OK.")
                # Ici on pourrait extraire les liens des semestres, etc.
                # print(tc_resp.text[:500])
            else:
                print(f"❌ Échec accès TC (Code: {tc_resp.status_code})")
                
        else:
            print("❌ ÉCHEC DE CONNEXION. Vérifiez les identifiants ou le CSRF.")
            # print(login_resp.text)
            
    except Exception as e:
        print(f"❌ Erreur technique : {e}")

if __name__ == "__main__":
    test_web_login()
