import requests
from bs4 import BeautifulSoup
import urllib3

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# === CONFIGURATION ===
BASE_URL = "https://scodoc.univ-lehavre.fr"
LOGIN_URL = f"{BASE_URL}/auth/login"
USERNAME = "pytels"
PASSWORD = "27041978"

def debug_login():
    session = requests.Session()
    session.verify = False
    
    # Headers très complets (simule un vrai Chrome)
    session.headers.update({
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8",
        "Accept-Language": "fr-FR,fr;q=0.9",
        "Origin": BASE_URL,
        "Referer": LOGIN_URL
    })

    print(f"--- ETAPE 1 : Chargement page de login ---")
    r1 = session.get(LOGIN_URL)
    print(f"Status GET: {r1.status_code}")
    
    soup = BeautifulSoup(r1.text, 'html.parser')
    csrf_token = soup.find('input', {'id': 'csrf_token'})['value']
    print(f"CSRF Token: {csrf_token}")
    print(f"Cookies initiaux: {session.cookies.get_dict()}")

    print(f"\n--- ETAPE 2 : Envoi POST ---")
    payload = {
        "csrf_token": csrf_token,
        "user_name": USERNAME,
        "password": PASSWORD,
        "submit": "Suivant"
    }
    
    # On ne suit pas les redirections automatiquement pour voir ce qui se passe
    r2 = session.post(LOGIN_URL, data=payload, allow_redirects=False)
    
    print(f"Status POST: {r2.status_code}")
    print(f"En-têtes réponse: {dict(r2.headers)}")
    print(f"Cookies après POST: {session.cookies.get_dict()}")
    
    if r2.status_code == 302:
        target = r2.headers.get('Location')
        print(f"🚀 Redirection détectée vers : {target}")
        
        # On suit la redirection manuellement
        r3 = session.get(f"{BASE_URL}{target}" if target.startswith('/') else target)
        print(f"Status après redirection: {r3.status_code}")
        if "Scolarité" in r3.text or "Déconnexion" in r3.text:
            print("🎉 SUCCÈS : Connecté !")
        else:
            print("❌ ÉCHEC : Toujours pas connecté sur la page cible.")
    else:
        print("❌ ÉCHEC : Pas de redirection (le serveur devrait rediriger après un login réussi).")
        # On cherche l'erreur dans le HTML
        error_soup = BeautifulSoup(r2.text, 'html.parser')
        flashes = error_soup.find_all(class_="flashes")
        if flashes:
            print(f"Message serveur: {flashes[0].text.strip()}")

if __name__ == "__main__":
    debug_login()
