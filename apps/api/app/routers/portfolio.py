from fastapi import APIRouter, HTTPException, Depends, UploadFile, File
from fastapi.responses import StreamingResponse, FileResponse, HTMLResponse
from sqlmodel import Session, select
from typing import List, Optional
from ..database import get_session
from ..models import User, PortfolioPage, StudentFile, ResponsibilityEntityType, StudentPPP, Internship
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

UPLOAD_DIR = "/app/uploads/portfolio"
os.makedirs(UPLOAD_DIR, exist_ok=True)

@router.get("/files/all", response_model=List[StudentFile])
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
        
    return session.exec(query.order_by(StudentFile.uploaded_at.desc())).all()

@router.get("/files", response_model=List[StudentFile])
async def list_student_files(student_uid: Optional[str] = None, session: Session = Depends(get_session), current_user: User = Depends(get_current_user)):
    uid = student_uid if student_uid else current_user.ldap_uid
    stmt = select(StudentFile).where(StudentFile.student_uid == uid)
    return session.exec(stmt).all()

@router.post("/upload")
async def upload_portfolio_file(
    entity_type: ResponsibilityEntityType,
    entity_id: str,
    academic_year: str = "2025-2026",
    file: UploadFile = File(...),
    session: Session = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    student_dir = os.path.join(UPLOAD_DIR, current_user.ldap_uid)
    os.makedirs(student_dir, exist_ok=True)
    
    file_path = os.path.join(student_dir, file.filename)
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
        
    db_file = StudentFile(
        student_uid=current_user.ldap_uid,
        filename=file.filename,
        nc_path=file_path,
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
