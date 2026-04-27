import requests
import sys

def get_token(user, password):
    url = "http://localhost:8080/realms/but-tc/protocol/openid-connect/token"
    data = {
        "client_id": "skills-hub-app",
        "client_secret": "skills_hub_secret_76",
        "grant_type": "password",
        "username": user,
        "password": password
    }
    try:
        r = requests.post(url, data=data, timeout=5)
        return "access_token" in r.json()
    except:
        return False

# On teste les comptes actuels
users = {"superprof": "superprof", "prof": "prof", "stud": "stud"}
for u, p in users.items():
    success = get_token(u, p)
    print(f"User {u}: {'OK' if success else 'FAILED'}")
