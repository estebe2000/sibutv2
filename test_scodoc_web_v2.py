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

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8",
    "Accept-Language": "fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7",
    "Referer": LOGIN_URL
}

def test_web_login():
    session = requests.Session()
    session.verify = False
    session.headers.update(HEADERS)
    
    print(f"🔍 [Phase 1] Lecture de la page : {LOGIN_URL}")
    
    try:
        # 1. Get initial cookies and CSRF
        r1 = session.get(LOGIN_URL)
        soup = BeautifulSoup(r1.text, 'html.parser')
        csrf_token = soup.find('input', {'id': 'csrf_token'})['value']
        print(f"✅ CSRF : {csrf_token[:15]}...")
        
        # 2. Login POST
        payload = {
            "csrf_token": csrf_token,
            "user_name": USERNAME,
            "password": PASSWORD,
            "submit": "Suivant"
        }
        
        print("🚀 [Phase 2] Envoi des identifiants...")
        r2 = session.post(LOGIN_URL, data=payload, allow_redirects=True)
        
        # Debug : que contient la réponse ?
        if "Déconnexion" in r2.text or "Scolarité" in r2.text:
            print("🎉 CONNEXION RÉUSSIE !")
            print(f"✅ URL finale : {r2.url}")
        else:
            print("❌ ÉCHEC.")
            # On cherche s'il y a un message d'erreur dans le HTML (flash message)
            error_soup = BeautifulSoup(r2.text, 'html.parser')
            flashes = error_soup.find_all(class_="flashes")
            if flashes:
                print(f"💬 Message du serveur : {[f.text.strip() for f in flashes]}")
            else:
                print("⚠️ Aucun message d'erreur trouvé, probablement rejeté avant le traitement.")
            
    except Exception as e:
        print(f"❌ Erreur technique : {e}")

if __name__ == "__main__":
    test_web_login()
