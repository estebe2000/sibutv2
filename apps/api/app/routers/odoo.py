from fastapi import APIRouter, HTTPException, BackgroundTasks, Depends
from pydantic import BaseModel
from app.services.odoo_service import odoo_service
import re

router = APIRouter()

class ProvisionRequest(BaseModel):
    email: str
    password: str 

def sanitize_db_name(email: str) -> str:
    name = email.split('@')[0]
    clean_name = re.sub(r'[^a-z0-9]', '-', name.lower())
    clean_name = clean_name.strip('-')
    return clean_name

@router.get("/list")
async def list_databases():
    """Liste toutes les instances Odoo (Admin only)"""
    try:
        dbs = odoo_service.list_databases()
        # On peut enrichir la liste avec des infos (taille, date créa) si on faisait du SQL direct
        return {"databases": dbs}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/{db_name}")
async def delete_database(db_name: str):
    """Supprime une instance Odoo (Irréversible)"""
    # Protection : Ne pas supprimer le master ou odoo principal
    PROTECTED_DBS = ["master-template", "odoo", "postgres"]
    if db_name in PROTECTED_DBS:
        raise HTTPException(status_code=403, detail="Suppression interdite pour cette base critique.")
    
    try:
        if not odoo_service.database_exists(db_name):
            raise HTTPException(status_code=404, detail="Base introuvable")
            
        odoo_service.drop_database(db_name)
        return {"status": "deleted", "db_name": db_name}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/{db_name}/reset-password")
async def reset_password(db_name: str):
    """Réinitialise le mot de passe admin de la base (copie depuis master)"""
    try:
        if not odoo_service.database_exists(db_name):
            raise HTTPException(status_code=404, detail="Base introuvable")
            
        success = odoo_service.reset_admin_password(db_name, "ignored")
        
        if success:
            return {"status": "reset", "message": "Mot de passe réinitialisé (identique au Master)"}
        else:
            raise HTTPException(status_code=500, detail="Échec du reset password")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/provision")
async def provision_odoo(request: ProvisionRequest, background_tasks: BackgroundTasks):
    db_name = sanitize_db_name(request.email)
    
    if odoo_service.database_exists(db_name):
        return {
            "status": "exists",
            "message": "Votre instance Odoo existe déjà.",
            "url": f"https://{db_name}.educ-ai.fr",
            "db_name": db_name
        }

    background_tasks.add_task(create_and_configure_db, db_name, request.email, request.password)

    return {
        "status": "provisioning",
        "message": "La création de votre instance a démarré.",
        "url": f"https://{db_name}.educ-ai.fr",
        "db_name": db_name
    }

def create_and_configure_db(db_name: str, email: str, password: str):
    try:
        MASTER_DB = "master-template" 
        if not odoo_service.database_exists(MASTER_DB):
            print(f"ERREUR: La base template '{MASTER_DB}' n'existe pas.")
            return

        print(f"Background: Duplication de {MASTER_DB} vers {db_name}...")
        odoo_service.duplicate_database(MASTER_DB, db_name)
        print(f"Background: Duplication terminée pour {db_name}.")
        
    except Exception as e:
        print(f"Background: ERREUR Provisioning {db_name} : {e}")