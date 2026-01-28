from sqlmodel import Session, select, create_engine
from models import Company
import os
import requests
import time

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://app_user:app_password@db:5432/skills_db")
engine = create_engine(DATABASE_URL)

def geocode_all():
    with Session(engine) as session:
        companies = session.exec(select(Company).where(Company.address != None)).all()
        print(f"Géocodage de {len(companies)} entreprises...")
        
        for c in companies:
            if c.latitude and c.longitude:
                continue
                
            try:
                print(f"Géocodage : {c.name} ({c.address})")
                res = requests.get(f"https://api-adresse.data.gouv.fr/search/?q={c.address}&limit=1")
                if res.status_code == 200:
                    data = res.json()
                    if data['features']:
                        coords = data['features'][0]['geometry']['coordinates']
                        # BAN retourne [longitude, latitude]
                        c.longitude = coords[0]
                        c.latitude = coords[1]
                        session.add(c)
                        print(f" -> OK : {c.latitude}, {c.longitude}")
                
                # Petit dodo pour respecter l'API publique
                time.sleep(0.1)
            except Exception as e:
                print(f" -> Erreur pour {c.name} : {e}")
                
        session.commit()
        print("Géocodage terminé.")

if __name__ == "__main__":
    geocode_all()
