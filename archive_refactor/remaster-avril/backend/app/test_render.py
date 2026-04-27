import httpx
import asyncio
from sqlmodel import Session, create_engine, select
import os
import sys

# Configuration identique au backend
DATABASE_URL = "postgresql://app_user:app_password@db:5432/skills_db"
engine = create_engine(DATABASE_URL)

async def test_render():
    print("🚀 Démarrage du test de rendu interne...")
    
    # 1. Vérification de la connectivité au relais
    try:
        async with httpx.AsyncClient() as client:
            resp = await client.get("http://172.18.0.1:8092/api/hierarchie")
            print(f"✅ Relais ScoDoc joint: {resp.status_code}")
    except Exception as e:
        print(f"❌ Échec relais ScoDoc: {e}")

    # 2. Test de l'endpoint via l'app (si elle tourne)
    try:
        # On va simplement vérifier si le backend répond 200 sur la route racine
        # car on ne peut pas bypasser le middleware de session facilement ici
        async with httpx.AsyncClient() as client:
            resp = await client.get("http://localhost:8000/", follow_redirects=True)
            print(f"✅ Backend répond: {resp.status_code}")
    except Exception as e:
        print(f"❌ Échec backend: {e}")

if __name__ == "__main__":
    asyncio.run(test_render())
