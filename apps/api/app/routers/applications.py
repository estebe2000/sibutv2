from fastapi import APIRouter, HTTPException, Depends
from sqlmodel import Session, select, col
from typing import List, Any
from ..database import get_session
from ..models import InternshipApplication, User, UserRole, ApplicationStatus
from ..dependencies import get_current_user

router = APIRouter()

@router.get("/", response_model=List[InternshipApplication])
async def get_my_applications(
    session: Session = Depends(get_session),
    current_user: Any = Depends(get_current_user)
):
    """Liste les candidatures de l'étudiant connecté"""
    # Seul l'étudiant peut voir ses propres candidatures
    # (Ou les profs pour suivi, mais restons focus étudiant)
    uid = current_user["ldap_uid"] if isinstance(current_user, dict) else current_user.ldap_uid
    
    statement = select(InternshipApplication).where(InternshipApplication.student_uid == uid).order_by(InternshipApplication.applied_at.desc())
    return session.exec(statement).all()

@router.post("/", response_model=InternshipApplication)
async def create_application(
    app: InternshipApplication,
    session: Session = Depends(get_session),
    current_user: Any = Depends(get_current_user)
):
    """Ajoute une candidature"""
    uid = current_user["ldap_uid"] if isinstance(current_user, dict) else current_user.ldap_uid
    app.student_uid = uid # Forcer l'UID de l'utilisateur connecté
    
    session.add(app)
    session.commit()
    session.refresh(app)
    return app

@router.patch("/{app_id}/", response_model=InternshipApplication)
async def update_application(
    app_id: int,
    data: dict,
    session: Session = Depends(get_session),
    current_user: Any = Depends(get_current_user)
):
    """Met à jour une candidature (ex: changer statut)"""
    uid = current_user["ldap_uid"] if isinstance(current_user, dict) else current_user.ldap_uid
    
    app = session.get(InternshipApplication, app_id)
    if not app or app.student_uid != uid:
        raise HTTPException(status_code=404, detail="Candidature non trouvée")
        
    for key, value in data.items():
        if hasattr(app, key):
            setattr(app, key, value)
            
    session.add(app)
    session.commit()
    session.refresh(app)
    return app

import requests

@router.delete("/{app_id}/")
async def delete_application(
    app_id: int,
    session: Session = Depends(get_session),
    current_user: Any = Depends(get_current_user)
):
    """Supprime une candidature"""
    uid = current_user["ldap_uid"] if isinstance(current_user, dict) else current_user.ldap_uid
    app = session.get(InternshipApplication, app_id)
    if not app or app.student_uid != uid:
        raise HTTPException(status_code=404)
        
    session.delete(app)
    session.commit()
    return {"status": "success"}

@router.get("/search-offers")
async def search_offers(
    query: str = "Marketing",
    location: str = "Rouen",
    radius: int = 30,
    current_user: Any = Depends(get_current_user)
):
    """
    Recherche des offres via l'API La Bonne Alternance (Gouv.fr)
    On cherche les offres d'emploi (offres), les formations (matcha) et les partenaires.
    """
    # LBA a besoin de coordonnées GPS pour la recherche
    # On géocode d'abord la ville demandée via API Adresse
    lat, lon = 49.4432, 1.0999 # Rouen par défaut
    insee_code = "76540" # Rouen par défaut
    
    try:
        geo_res = requests.get(f"https://api-adresse.data.gouv.fr/search/?q={location}&limit=1")
        if geo_res.status_code == 200 and geo_res.json()['features']:
            feature = geo_res.json()['features'][0]
            coords = feature['geometry']['coordinates']
            lon, lat = coords[0], coords[1]
            insee_code = feature['properties'].get('citycode', insee_code)
    except Exception:
        pass # Fallback Rouen

    # Appel LBA
    lba_url = "https://labonnealternance.apprentissage.beta.gouv.fr/api/v1/jobs"
    default_romes = "M1705,M1703,E1103,M1707"
    
    try:
        # 1. Trouver les ROMES à partir du mot clé (on force "stage" pour orienter)
        rome_res = requests.get(f"https://labonnealternance.apprentissage.beta.gouv.fr/api/v1/metiers?title={query} stage")
        romes = ""
        if rome_res.status_code == 200:
            metiers = rome_res.json().get('labelsAndRomes', [])
            all_romes = []
            for m in metiers:
                all_romes.extend(m.get('romes', []))
            romes = ",".join(list(set(all_romes))[:15])
        
        if not romes:
            romes = default_romes 

        # 2. Chercher les jobs
        params = {
            "romes": romes,
            "latitude": lat,
            "longitude": lon,
            "radius": 60,
            "insee": insee_code,
            "caller": "but-tc-skills-hub",
            "sources": "offres,matcha" 
        }
        
        response = requests.get(lba_url, params=params)
        if response.status_code != 200:
            return {"results": []}
            
        data = response.json()
        results = []
        
        def is_internship(job):
            title = (job.get('title') or '').lower()
            jt = job.get('job', {})
            contract = (jt.get('contractType') or '').lower()
            return any(x in title or x in contract for x in ['stage', 'stagiaire', 'internship'])

        # On traite les sources : matchas, peJobs, et partnerJobs
        sources_map = [
            ('matchas', 'LBA (Alternance)'),
            ('peJobs', 'France Travail'),
            ('partnerJobs', 'Partenaire')
        ]

        for key, source_label in sources_map:
            for job in data.get(key, {}).get('results', []):
                # Normalisation du nom de l'entreprise (CRITIQUE pour le NotNull en DB)
                raw_company = job.get('company', {})
                company_name = raw_company.get('name') or "Entreprise"
                if company_name == "Enseigne inconnue":
                    company_name = "Confidentiel"
                
                jt = job.get('job', {})
                c_type = jt.get('contractType') or 'Alternance'
                is_st = is_internship(job)

                results.append({
                    "id": job.get('id'),
                    "title": job.get('title') or "Offre sans titre",
                    "company": company_name,
                    "place": job.get('place', {}).get('city') or location,
                    "url": job.get('url'),
                    "source": source_label,
                    "contract": "STAGE" if is_st else c_type,
                    "is_internship": is_st
                })

        # Tri : Stages en premier
        results.sort(key=lambda x: x['is_internship'], reverse=True)
        return {"results": results}

    except Exception as e:
        print(f"Error searching LBA: {e}")
        return {"results": []}
