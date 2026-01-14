from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from sqlmodel import Session, select
from typing import List
from ..database import get_session
from ..models import StudentFile, ResponsibilityEntityType, UserRole
from ..dependencies import get_current_user, require_staff
from ..services.nextcloud_service import nc_service

router = APIRouter(prefix="/portfolio", tags=["Portfolio"])

@router.get("/files", response_model=List[StudentFile])
def list_my_files(
    entity_type: ResponsibilityEntityType = None, 
    entity_id: str = None, 
    session: Session = Depends(get_session),
    current_user: any = Depends(get_current_user)
):
    """
    Liste les fichiers de l'étudiant, optionnellement filtrés par activité/ressource.
    """
    query = select(StudentFile).where(StudentFile.student_uid == current_user.ldap_uid)
    if entity_type:
        query = query.where(StudentFile.entity_type == entity_type)
    if entity_id:
        query = query.where(StudentFile.entity_id == entity_id)
    
    return session.exec(query).all()

@router.post("/upload")
async def upload_proof(
    entity_type: ResponsibilityEntityType,
    entity_id: str,
    file: UploadFile = File(...), 
    session: Session = Depends(get_session),
    current_user: any = Depends(get_current_user)
):
    """
    Upload une preuve et l'enregistre en base.
    """
    content = await file.read()
    safe_filename = file.filename.replace(" ", "_")
    
    # Upload physique sur Nextcloud (dans un sous-dossier par entité pour l'organisation)
    subfolder = f"{entity_type}_{entity_id}"
    nc_path = nc_service.upload_file(current_user.ldap_uid, safe_filename, content, subfolder)
    
    # Enregistrement en base
    new_file = StudentFile(
        student_uid=current_user.ldap_uid,
        filename=safe_filename,
        nc_path=nc_path,
        entity_type=entity_type,
        entity_id=entity_id
    )
    session.add(new_file)
    session.commit()
    session.refresh(new_file)
    
    return new_file

@router.delete("/files/{file_id}")
def delete_file(
    file_id: int, 
    session: Session = Depends(get_session),
    current_user: any = Depends(get_current_user)
):
    """
    Supprime un fichier si non verrouillé.
    """
    db_file = session.get(StudentFile, file_id)
    if not db_file:
        raise HTTPException(status_code=404, detail="File not found")
    
    # Vérification propriété
    if db_file.student_uid != current_user.ldap_uid and current_user.role == UserRole.STUDENT:
        raise HTTPException(status_code=403, detail="Not your file")
    
    # Vérification verrou (les étudiants ne peuvent pas supprimer si verrouillé)
    if db_file.is_locked and current_user.role == UserRole.STUDENT:
        raise HTTPException(status_code=403, detail="File is locked by a teacher")

    # Suppression Nextcloud (optionnel selon stratégie, ici on supprime)
    # nc_service.delete_file(db_file.nc_path) 
    
    session.delete(db_file)
    session.commit()
    return {"status": "success"}

@router.post("/files/{file_id}/lock")
def toggle_file_lock(
    file_id: int, 
    lock: bool = True,
    session: Session = Depends(get_session),
    current_user: any = Depends(require_staff)
):
    """
    (Staff uniquement) Verrouille ou déverrouille un fichier.
    """
    db_file = session.get(StudentFile, file_id)
    if not db_file:
        raise HTTPException(status_code=404, detail="File not found")
    
    db_file.is_locked = lock
    session.add(db_file)
    session.commit()
    return {"status": "success", "is_locked": db_file.is_locked}