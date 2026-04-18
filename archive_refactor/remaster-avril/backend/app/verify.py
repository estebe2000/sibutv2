import os
import sys
from fastapi.testclient import TestClient
from sqlmodel import Session, create_engine, select
from app.main import app, engine
from app.models.models import User, Promotion, Group

client = TestClient(app)

def check_route(url, expected_strings):
    print(f"🔍 Testing {url}...")
    # On mock la session pour bypasser le login Keycloak pendant le test technique
    with client as c:
        # Simulation d'un utilisateur admin en base
        with Session(engine) as session:
            admin = session.exec(select(User).where(User.role == "ADMIN")).first()
            if not admin:
                print("⚠️ No admin user found for testing, skipping UI content check.")
                return False
            
            # Injection d'une session fictive
            with c.session_transaction() as sess:
                sess['user'] = {'preferred_username': admin.ldap_uid}
        
        response = c.get(url)
        if response.status_code != 200:
            print(f"❌ Route {url} returned {response.status_code}")
            return False
        
        for s in expected_strings:
            if s not in response.text:
                print(f"❌ Missing expected string '{s}' in {url}")
                return False
    print(f"✅ Route {url} is valid.")
    return True

def run_all_tests():
    print("🚀 --- WINSTON AUTO-VALIDATION ---")
    
    # 1. Vérification des routes critiques
    results = [
        check_route("/", ["Tableau de Bord"]),
        check_route("/effectifs", ["BUT 1", "BUT 2", "BUT 3", "Matrice"]),
        check_route("/synchro-scodoc", ["Synchro", "BUT1", "BUT2", "BUT3"])
    ]
    
    if all(results):
        print("🟢 ALL SYSTEMS OPERATIONAL")
        sys.exit(0)
    else:
        print("🔴 SYSTEM FAILURE DETECTED")
        sys.exit(1)

if __name__ == "__main__":
    run_all_tests()
