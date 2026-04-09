from flask import Flask, request
import requests
from bs4 import BeautifulSoup
import urllib3

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

app = Flask(__name__)

TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <title>ScoDoc Tester</title>
    <meta charset="utf-8">
    <style>
        body { font-family: sans-serif; padding: 2rem; background: #f0f2f5; }
        .card { background: white; padding: 2rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); max-width: 600px; margin: 0 auto; }
        h1 { color: #1a73e8; text-align: center; }
        input { width: 100%; padding: 10px; margin: 10px 0; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; }
        button { width: 100%; background: #1a73e8; color: white; padding: 10px; border: none; border-radius: 4px; cursor: pointer; font-size: 16px; }
        button:hover { background: #1557b0; }
        .result { margin-top: 20px; padding: 15px; border-radius: 4px; white-space: pre-wrap; word-break: break-all; }
        .success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
    </style>
</head>
<body>
    <div class="card">
        <h1>🔍 ScoDoc Tester</h1>
        <form method="POST">
            <label>URL</label>
            <input type="text" name="url" value="https://scodoc.univ-lehavre.fr" required>
            <label>Login</label>
            <input type="text" name="username" value="pytels" required>
            <label>Password</label>
            <input type="password" name="password" required>
            <button type="submit">Tester la connexion</button>
        </form>
        REPLACE_ME
    </div>
</body>
</html>
"""

@app.route("/", methods=["GET", "POST"])
def home():
    result_html = ""
    if request.method == "POST":
        base_url = request.form.get("url").rstrip("/")
        username = request.form.get("username")
        password = request.form.get("password")
        login_url = f"{base_url}/auth/login"
        
        session = requests.Session()
        session.verify = False
        session.headers.update({"User-Agent": "Mozilla/5.0"})

        try:
            # 1. CSRF
            r1 = session.get(login_url)
            soup = BeautifulSoup(r1.text, 'html.parser')
            csrf = soup.find('input', {'id': 'csrf_token'})
            
            if not csrf:
                result_html = f'<div class="result error">❌ Pas de CSRF trouvé sur {login_url}</div>'
            else:
                token = csrf['value']
                # 2. Login
                payload = {"csrf_token": token, "user_name": username, "password": password, "submit": "Suivant"}
                r2 = session.post(login_url, data=payload)
                
                if "Déconnexion" in r2.text or "Scolarité" in r2.text:
                    result_html = f'<div class="result success">✅ <b>CONNEXION RÉUSSIE !</b><br>Session active.</div>'
                    # Test API
                    api_res = session.post(f"{base_url}/ScoDoc/api/tokens", json={"username": username, "password": password})
                    if api_res.status_code == 200:
                        result_html += f'<div class="result success">✅ API ACCESSIBLE (Token OK)</div>'
                    else:
                        result_html += f'<div class="result error">⚠️ API REFUSÉE (Code {api_res.status_code})<br>Activez "Utilisateur API" dans ScoDoc.</div>'
                else:
                    result_html = f'<div class="result error">❌ ÉCHEC LOGIN (Pas de redirection/session).</div>'

        except Exception as e:
            result_html = f'<div class="result error">❌ ERREUR : {str(e)}</div>'

    return TEMPLATE.replace("REPLACE_ME", result_html)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8091)