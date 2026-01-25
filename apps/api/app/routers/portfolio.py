from fastapi import APIRouter, HTTPException, Depends, UploadFile, File
from sqlmodel import Session, select
from typing import List, Optional
from ..database import get_session
from ..models import User, PortfolioPage, StudentFile, ResponsibilityEntityType
from ..dependencies import get_current_user
from datetime import datetime
import os
import shutil

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
        nc_path=file_path, # Path local pour l'instant
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
    
    # Sécurité : seul l'étudiant proprio ou un prof peut supprimer
    if db_file.student_uid != current_user.ldap_uid and current_user.role == "STUDENT":
        raise HTTPException(status_code=403)
        
    if db_file.is_locked:
        raise HTTPException(status_code=403, detail="File is locked")
        
    if os.path.exists(db_file.nc_path):
        os.remove(db_file.nc_path)
        
    session.delete(db_file)
    session.commit()
    return {"status": "success"}