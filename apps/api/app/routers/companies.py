from fastapi import APIRouter, HTTPException, Depends, Query
from sqlmodel import Session, select, col, func
from typing import Optional, List, Any
from ..database import get_session
from ..models import User, Company, UserRole, Internship
from ..dependencies import get_current_user

router = APIRouter()

@router.get("/", response_model=List[Company])
async def get_companies(
    search: Optional[str] = None, 
    session: Session = Depends(get_session),
    current_user: Any = Depends(get_current_user)
):
    """Récupère la liste des entreprises avec recherche optionnelle"""
    statement = select(Company)
    if search:
        statement = statement.where(col(Company.name).ilike(f"%{search}%"))
    
    # Récupérer le rôle de manière sûre (dict ou objet)
    role = current_user["role"] if isinstance(current_user, dict) else current_user.role

    # Si c'est un étudiant, on ne montre que celles visibles
    if role == UserRole.STUDENT:
        statement = statement.where(Company.visible_to_students == True)
        
    return session.exec(statement).all()

@router.post("/", response_model=Company)
async def create_company(
    company: Company, 
    session: Session = Depends(get_session),
    current_user: Any = Depends(get_current_user)
):
    """Crée une nouvelle entreprise dans le Codex"""
    # Vérifier si elle existe déjà par son nom
    existing = session.exec(select(Company).where(Company.name == company.name)).first()
    if existing:
        return existing
        
    session.add(company)
    session.commit()
    session.refresh(company)
    return company

@router.get("/{company_id}", response_model=Company)
async def get_company(company_id: int, session: Session = Depends(get_session)):
    company = session.get(Company, company_id)
    if not company:
        raise HTTPException(status_code=404, detail="Entreprise non trouvée")
    return company

@router.patch("/{company_id}", response_model=Company)
async def update_company(
    company_id: int, 
    data: dict, 
    session: Session = Depends(get_session),
    current_user: Any = Depends(get_current_user)
):
    """Met à jour une entreprise"""
    role = current_user["role"] if isinstance(current_user, dict) else current_user.role

    # Seuls les profs/admins peuvent modifier (pour l'instant, à affiner si besoin)
    if role == UserRole.STUDENT and company_id:
        # On pourrait autoriser l'étudiant à mettre à jour "sa" boite s'il vient de la créer
        # Mais restons simple : le staff gère le Codex.
        pass

    company = session.get(Company, company_id)
    if not company:
        raise HTTPException(status_code=404, detail="Entreprise non trouvée")
    
    for key, value in data.items():
        if hasattr(company, key):
            setattr(company, key, value)
            
    session.add(company)
    session.commit()
    session.refresh(company)
    return company

@router.get("/{company_id}/stats")
async def get_company_stats(company_id: int, session: Session = Depends(get_session)):
    """Nombre de stagiaires total pour cette entreprise"""
    count = session.exec(select(func.count(Internship.id)).where(Internship.company_id == company_id)).one()
    return {"total_interns": count}

@router.get("/{company_id}/internships")
async def get_company_internships(
    company_id: int, 
    session: Session = Depends(get_session),
    current_user: Any = Depends(get_current_user)
):
    """Récupère l'historique des stages pour une entreprise"""
    role = current_user["role"] if isinstance(current_user, dict) else current_user.role
    if role == UserRole.STUDENT:
        raise HTTPException(status_code=403, detail="Accès réservé au personnel")

    # Jointure pour avoir le nom de l'étudiant
    statement = select(Internship, User).join(User, Internship.student_uid == User.ldap_uid).where(Internship.company_id == company_id).order_by(Internship.academic_year.desc())
    results = session.exec(statement).all()
    
    # On retourne un format simplifié
    return [
        {
            "id": i.id,
            "academic_year": i.academic_year,
            "student_name": u.full_name,
            "student_uid": i.student_uid,
            "start_date": i.start_date,
            "end_date": i.end_date,
            "supervisor_name": i.supervisor_name,
            "is_active": i.is_active
        } 
        for i, u in results
    ]


@router.delete("/{company_id}")
async def delete_company(
    company_id: int, 
    session: Session = Depends(get_session),
    current_user: Any = Depends(get_current_user)
):
    """Supprime une entreprise SI elle n'a aucun stage lié"""
    # Vérification Staff
    role = current_user["role"] if isinstance(current_user, dict) else current_user.role
    if role == UserRole.STUDENT:
        raise HTTPException(status_code=403, detail="Accès réservé au personnel")

    company = session.get(Company, company_id)
    if not company:
        raise HTTPException(status_code=404, detail="Entreprise non trouvée")

    # Vérifier s'il y a des stages liés
    count = session.exec(select(func.count(Internship.id)).where(Internship.company_id == company_id)).one()
    if count > 0:
        raise HTTPException(
            status_code=400, 
            detail=f"Impossible de supprimer : cette entreprise est liée à {count} stage(s)."
        )

    session.delete(company)
    session.commit()
    return {"status": "success", "message": "Entreprise supprimée"}
