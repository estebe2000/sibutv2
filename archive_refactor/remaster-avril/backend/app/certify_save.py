from fastapi.testclient import TestClient
from app.main import app
from app.core.security import admin_only
from sqlmodel import Session, create_engine, select
from app.models.models import LearningOutcome
from app.core.config import settings

# On simule un utilisateur authentifié pour le test
async def mock_admin():
    return True

app.dependency_overrides[admin_only] = mock_admin
client = TestClient(app)

def certify_fix():
    test_content = "### PREUVE_CERTIFIEE_SENIOR\n- Unite: OK\n- Flux: OK"
    print(f"--- LANCEMENT DE LA CERTIFICATION ---")
    
    # 1. Envoi de la requête POST (Simule le clic sur 'Enregistrer')
    response = client.post("/admin/ac-save-v2", data={
        "ac_id": "1",
        "description": test_content
    })
    
    if response.status_code == 200 and response.text == "OK":
        print("✅ Etape 1: Le serveur a accepté le POST et répondu OK")
    else:
        print(f"❌ Etape 1: Echec (Status: {response.status_code}, Reponse: {response.text})")
        return

    # 2. Vérification directe en Base de Données
    engine = create_engine(settings.DATABASE_URL)
    with Session(engine) as session:
        ac = session.get(LearningOutcome, 1)
        if ac.description == test_content:
            print(f"✅ Etape 2: La Base de Données contient le contenu exact.")
            print(f"--- RESULTAT: CERTIFICATION REUSSIE ---")
        else:
            print(f"❌ Etape 2: Donnée DB incohérente. Contenu: {ac.description[:20]}...")

if __name__ == "__main__":
    certify_fix()
