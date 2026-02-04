from fastapi import APIRouter, HTTPException, Depends, UploadFile, File
from fastapi.responses import StreamingResponse, FileResponse, HTMLResponse
from sqlmodel import Session, select
from typing import List, Optional
from ..database import get_session
from ..models import User, PortfolioPage, StudentFile, ResponsibilityEntityType, StudentPPP, Internship, Activity
from ..dependencies import get_current_user
from datetime import datetime
import os
import shutil
import json

router = APIRouter(tags=["Portfolio"])

# --- PAGES ---

@router.get("/pages", response_model=List[PortfolioPage])
async def list_portfolio_pages(student_uid: Optional[str] = None, session: Session = Depends(get_session), current_user: User = Depends(get_current_user)):
    uid = student_uid if student_uid else current_user.ldap_uid
    stmt = select(PortfolioPage).where(PortfolioPage.student_uid == uid).order_by(PortfolioPage.updated_at.desc())
    return session.exec(stmt).all()

@router.get("/pages/{page_id}", response_model=PortfolioPage)
async def get_portfolio_page(page_id: int, session: Session = Depends(get_session)):
    page = session.get(PortfolioPage, page_id)
    if not page: raise HTTPException(status_code=404, detail="Page non trouvée")
    return page

@router.post("/pages", response_model=PortfolioPage)
async def create_portfolio_page(page: PortfolioPage, session: Session = Depends(get_session)):
    session.add(page)
    session.commit()
    session.refresh(page)
    return page

@router.patch("/pages/{page_id}", response_model=PortfolioPage)
async def update_portfolio_page(page_id: int, page_data: dict, session: Session = Depends(get_session)):
    page = session.get(PortfolioPage, page_id)
    if not page: raise HTTPException(status_code=404, detail="Page non trouvée")
    
    for key, value in page_data.items():
        if hasattr(page, key):
            setattr(page, key, value)
    
    page.updated_at = datetime.now()
    session.add(page)
    session.commit()
    session.refresh(page)
    return page

@router.delete("/pages/{page_id}")
async def delete_portfolio_page(page_id: int, session: Session = Depends(get_session)):
    page = session.get(PortfolioPage, page_id)
    if not page: raise HTTPException(status_code=404, detail="Page non trouvée")
    session.delete(page)
    session.commit()
    return {"status": "success"}

# --- FILES ---

# Chemin vers le volume partagé Nextcloud
# Structure : /nextcloud_data/data/<user>/files/...
UPLOAD_DIR = "/nextcloud_data/data/hub-service/files/app/uploads/portfolio"
# Fallback pour le dev local sans volume partagé
if not os.path.exists("/nextcloud_data"):
    UPLOAD_DIR = "/app/uploads/portfolio"

os.makedirs(UPLOAD_DIR, exist_ok=True)

class StudentFileRead(StudentFile):
    entity_title: Optional[str] = None

@router.get("/files/all", response_model=List[StudentFileRead])
async def list_all_student_files(
    entity_type: Optional[ResponsibilityEntityType] = None,
    academic_year: Optional[str] = None,
    session: Session = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    if current_user.role not in ["PROFESSOR", "ADMIN", "SUPER_ADMIN", "DEPT_HEAD", "STUDY_DIRECTOR"]:
        raise HTTPException(status_code=403, detail="Accès réservé aux enseignants")
        
    query = select(StudentFile)
    if entity_type:
        query = query.where(StudentFile.entity_type == entity_type)
    if academic_year:
        query = query.where(StudentFile.academic_year == academic_year)
        
    files = session.exec(query.order_by(StudentFile.uploaded_at.desc())).all()
    
    enriched_files = []
    activity_cache = {}
    internship_cache = {}
    
    for f in files:
        f_read = StudentFileRead.model_validate(f)
        f_read.entity_title = "Dossier"
        
        if f.entity_type == ResponsibilityEntityType.ACTIVITY:
            if f.entity_id in activity_cache:
                f_read.entity_title = activity_cache[f.entity_id]
            else:
                try:
                    act = session.get(Activity, int(f.entity_id))
                    title = f"{act.code} - {act.label}" if act else f"Activité #{f.entity_id}"
                    activity_cache[f.entity_id] = title
                    f_read.entity_title = title
                except:
                    f_read.entity_title = f"Activité #{f.entity_id}"
        
        elif f.entity_type == ResponsibilityEntityType.INTERNSHIP:
             if f.entity_id in internship_cache:
                f_read.entity_title = internship_cache[f.entity_id]
             else:
                try:
                    intern = session.get(Internship, int(f.entity_id))
                    title = f"Stage {intern.company_name}" if intern and intern.company_name else f"Stage #{f.entity_id}"
                    internship_cache[f.entity_id] = title
                    f_read.entity_title = title
                except:
                    f_read.entity_title = f"Stage #{f.entity_id}"
        
        elif f.entity_type == ResponsibilityEntityType.PPP:
            f_read.entity_title = "Projet Personnel et Professionnel"

        enriched_files.append(f_read)
        
    return enriched_files

@router.get("/files", response_model=List[StudentFile])
async def list_student_files(student_uid: Optional[str] = None, session: Session = Depends(get_session), current_user: User = Depends(get_current_user)):
    uid = student_uid if student_uid else current_user.ldap_uid
    stmt = select(StudentFile).where(StudentFile.student_uid == uid)
    return session.exec(stmt).all()

from webdav4.client import Client as WebDavClient

# ...

@router.post("/upload")
async def upload_portfolio_file(
    entity_type: ResponsibilityEntityType,
    entity_id: str,
    academic_year: str = "2025-2026",
    file: UploadFile = File(...),
    session: Session = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    # Configuration WebDAV
    nc_url = os.getenv("NEXTCLOUD_URL", "http://but_tc_nextcloud")
    nc_user = os.getenv("NEXTCLOUD_SERVICE_USER", "hub-service")
    nc_pass = os.getenv("NEXTCLOUD_SERVICE_PASS")
    
    # Chemin cible : Documents/portfolio/uid/filename
    # On utilise "Documents" car il existe par défaut
    target_dir_root = "Documents/portfolio"
    target_user_dir = f"{target_dir_root}/{current_user.ldap_uid}"
    target_path = f"{target_user_dir}/{file.filename}"
    
    db_path = target_path 

    try:
        client = WebDavClient(nc_url + "/remote.php/dav/files/" + nc_user, auth=(nc_user, nc_pass))
        
        # Création des dossiers si nécessaire
        if not client.exists(target_dir_root): client.mkdir(target_dir_root)
        if not client.exists(target_user_dir): client.mkdir(target_user_dir)
        
        # Upload du fichier via WebDAV
        client.upload_fileobj(file.file, target_path, overwrite=True)
        
    except Exception as e:
        print(f"WebDAV Error: {e}")
        raise HTTPException(status_code=500, detail=f"Erreur upload Nextcloud: {str(e)}")
        
    db_file = StudentFile(
        student_uid=current_user.ldap_uid,
        filename=file.filename,
        nc_path=db_path, # Chemin relatif propre
        entity_type=entity_type,
        entity_id=entity_id,
        academic_year=academic_year
    )
    session.add(db_file)
    session.commit()
    session.refresh(db_file)
    return db_file

@router.delete("/files/{file_id}")
async def delete_student_file(file_id: int, session: Session = Depends(get_session), current_user: User = Depends(get_current_user)):
    db_file = session.get(StudentFile, file_id)
    if not db_file: raise HTTPException(status_code=404)
    
    if db_file.student_uid != current_user.ldap_uid and current_user.role == "STUDENT":
        raise HTTPException(status_code=403)
        
    if db_file.is_locked:
        raise HTTPException(status_code=403, detail="File is locked")
        
    if os.path.exists(db_file.nc_path):
        os.remove(db_file.nc_path)
        
    session.delete(db_file)
    session.commit()
    return {"status": "success"}

@router.get("/download/{file_id}")
async def download_portfolio_file(file_id: int, session: Session = Depends(get_session), current_user: User = Depends(get_current_user)):
    db_file = session.get(StudentFile, file_id)
    if not db_file: raise HTTPException(status_code=404)
    
    is_staff = current_user.role in ["PROFESSOR", "ADMIN", "SUPER_ADMIN", "DEPT_HEAD", "STUDY_DIRECTOR"]
    if db_file.student_uid != current_user.ldap_uid and not is_staff:
        raise HTTPException(status_code=403)
        
    if not os.path.exists(db_file.nc_path):
        raise HTTPException(status_code=404, detail="File not found on disk")
        
    return FileResponse(db_file.nc_path, filename=db_file.filename)

import requests
import xml.etree.ElementTree as ET

# ... imports existants ...

@router.get("/share-link/{file_id}")
async def get_nextcloud_share_link(file_id: int, session: Session = Depends(get_session), current_user: User = Depends(get_current_user)):
    # 1. Vérification des droits
    db_file = session.get(StudentFile, file_id)
    if not db_file: raise HTTPException(status_code=404, detail="Fichier introuvable")
    
    is_staff = current_user.role in ["PROFESSOR", "ADMIN", "SUPER_ADMIN", "DEPT_HEAD", "STUDY_DIRECTOR"]
    if db_file.student_uid != current_user.ldap_uid and not is_staff:
        raise HTTPException(status_code=403, detail="Accès refusé")

    # 2. Configuration Nextcloud
    nc_internal_url = os.getenv("NEXTCLOUD_URL", "http://but_tc_nextcloud")
    nc_public_url = "https://nextcloud.educ-ai.fr"
    nc_user = os.getenv("NEXTCLOUD_SERVICE_USER", "hub-service")
    nc_pass = os.getenv("NEXTCLOUD_SERVICE_PASS")

    # Le chemin dans Nextcloud est relatif à la racine de l'utilisateur hub-service
    # db_file.nc_path est maintenant un chemin relatif "Documents/portfolio/..."
    file_path = db_file.nc_path
    
    # Nettoyage de sécurité au cas où
    if file_path.startswith("/"): file_path = file_path[1:]
    
    # Si c'est un ancien chemin, on tente de le nettoyer
    if "/files/" in file_path:
        file_path = file_path.split("/files/", 1)[1]

    # 3. Appel API OCS pour créer/récupérer le partage
    ocs_url = f"{nc_internal_url}/ocs/v2.php/apps/files_sharing/api/v1/shares"
    auth = (nc_user, nc_pass)
    headers = {"OCS-APIRequest": "true"}
    data = {
        "path": file_path,
        "shareType": 3, # 3 = Public Link
        "permissions": 1 # 1 = Read Only
    }

    try:
        # On tente de créer le partage
        response = requests.post(ocs_url, auth=auth, headers=headers, data=data, timeout=5)
        
        # Si le partage existe déjà (403), on doit le récupérer
        if response.status_code == 403 or "already exists" in response.text:
            # On liste les partages pour ce fichier
            get_params = {"path": file_path, "reshares": "false"}
            list_resp = requests.get(ocs_url, auth=auth, headers=headers, params=get_params, timeout=5)
            root = ET.fromstring(list_resp.content)
            # On cherche le token/url dans le XML
            token = root.find(".//token").text
            return {"url": f"{nc_public_url}/s/{token}"}
        
        elif response.status_code == 200:
            root = ET.fromstring(response.content)
            url = root.find(".//url").text
            # L'URL retournée par Nextcloud interne peut être http://but_tc_nextcloud/s/...
            # On force l'URL publique
            token = url.split("/")[-1]
            return {"url": f"{nc_public_url}/s/{token}"}
            
        else:
            print(f"NC Error: {response.text}")
            raise HTTPException(status_code=500, detail="Erreur Nextcloud Share")

    except Exception as e:
        print(f"Exception Share: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Erreur connexion Nextcloud: {str(e)}")

# --- PPP ---

@router.get("/ppp", response_model=StudentPPP)
async def get_my_ppp(session: Session = Depends(get_session), current_user: User = Depends(get_current_user)):
    ppp = session.exec(select(StudentPPP).where(StudentPPP.student_uid == current_user.ldap_uid)).first()
    if not ppp:
        ppp = StudentPPP(student_uid=current_user.ldap_uid)
        session.add(ppp)
        session.commit()
        session.refresh(ppp)
    return ppp

@router.patch("/ppp", response_model=StudentPPP)
async def update_my_ppp(data: dict, session: Session = Depends(get_session), current_user: User = Depends(get_current_user)):
    ppp = session.exec(select(StudentPPP).where(StudentPPP.student_uid == current_user.ldap_uid)).first()
    if not ppp: raise HTTPException(status_code=404)
    
    for key, value in data.items():
        if hasattr(ppp, key):
            setattr(ppp, key, value)
            
    ppp.updated_at = datetime.now()
    session.add(ppp)
    session.commit()
    session.refresh(ppp)
    return ppp

# --- EXPORT ---

@router.get("/export/html")
async def export_portfolio_html(student_uid: str, color: str = "#1971c2", session: Session = Depends(get_session)):
    user = session.exec(select(User).where(User.ldap_uid == student_uid)).first()
    if not user: raise HTTPException(status_code=404)
    
    ppp = session.exec(select(StudentPPP).where(StudentPPP.student_uid == student_uid)).first()
    pages = session.exec(select(PortfolioPage).where(PortfolioPage.student_uid == student_uid)).all()
    internships = session.exec(select(Internship).where(Internship.student_uid == student_uid)).all()

    html_content = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <title>Portfolio - {user.full_name}</title>
        <style>
            :root {{ --primary: {color}; }}
            body {{ font-family: 'Segoe UI', sans-serif; line-height: 1.6; color: #333; max-width: 900px; margin: 0 auto; padding: 40px; background: #f8f9fa; }}
            header {{ text-align: center; border-bottom: 4px solid var(--primary); padding-bottom: 20px; margin-bottom: 40px; background: white; padding: 40px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }}
            h1 {{ color: var(--primary); margin: 0; }}
            section {{ background: white; padding: 30px; margin-bottom: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }}
            h2 {{ border-left: 5px solid var(--primary); padding-left: 15px; color: #444; }}
            .badge {{ display: inline-block; padding: 4px 12px; background: var(--primary); color: white; border-radius: 20px; font-size: 0.8em; font-weight: bold; }}
            .page-card {{ border: 1px solid #eee; padding: 20px; margin-top: 15px; border-radius: 5px; }}
            .footer {{ text-align: center; font-size: 0.8em; color: #888; margin-top: 50px; }}
            .ppp-box {{ background: #e7f5ff; border: 1px solid #a5d8ff; padding: 20px; border-radius: 5px; }}
        </style>
    </head>
    <body>
        <header>
            <div class="badge">BUT TECHNIQUES DE COMMERCIALISATION</div>
            <h1>{user.full_name}</h1>
            <p>{user.email} | Étudiant à l'IUT du Havre</p>
        </header>

        <section>
            <h2>Mon Projet Professionnel (PPP)</h2>
            <div class="ppp-box">
                <strong>Objectifs :</strong> {ppp.career_goals if ppp and ppp.career_goals else "Non renseigné"}<br><br>
                <strong>Réflexion :</strong> {ppp.content_json if ppp and ppp.content_json else ""}
            </div>
        </section>

        <section>
            <h2>Mes Réflexions de Compétences</h2>
            {"".join([f'<div class="page-card"><h3>{p.title}</h3><p><em>Mis à jour le {p.updated_at.strftime("%d/%m/%Y")}</em></p></div>' for p in pages])}
        </section>

        <section>
            <h2>Expériences Professionnelles</h2>
            {"".join([f'<div class="page-card"><strong>{i.company_name}</strong> - Du {i.start_date.strftime("%d/%m/%Y") if i.start_date else ""} au {i.end_date.strftime("%d/%m/%Y") if i.end_date else ""}<br>{i.supervisor_name}</div>' for i in internships])}
        </section>

        <div class="footer">
            Généré automatiquement par Skills Hub - {datetime.now().strftime("%d/%m/%Y %H:%M")}
        </div>
    </body>
    </html>
    """
    return HTMLResponse(html_content)

@router.get("/export/pdf")
async def export_portfolio_pdf(student_uid: str, color: str = "#1971c2", session: Session = Depends(get_session)):
    user = session.exec(select(User).where(User.ldap_uid == student_uid)).first()
    if not user: raise HTTPException(status_code=404)
    
    ppp = session.exec(select(StudentPPP).where(StudentPPP.student_uid == student_uid)).first()
    pages = session.exec(select(PortfolioPage).where(PortfolioPage.student_uid == student_uid)).all()
    internships = session.exec(select(Internship).where(Internship.student_uid == student_uid)).all()

    from ..services.pdf_portfolio_service import generate_portfolio_pdf
    pdf_buffer = generate_portfolio_pdf(user, ppp, pages, internships, accent_color=color)
    
    filename = f"Portfolio_{user.full_name.replace(' ', '_')}.pdf"
    return StreamingResponse(
        pdf_buffer, 
        media_type="application/pdf",
        headers={"Content-Disposition": f"attachment; filename={filename}"}
    )
