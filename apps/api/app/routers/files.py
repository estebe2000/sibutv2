from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from fastapi.responses import StreamingResponse
from fastapi.staticfiles import StaticFiles
from sqlmodel import Session, select
from typing import List
import os
import io
import json
import pandas as pd
from ..database import get_session
from ..models import Activity, Resource, Competency, Group, User, UserRole
from ..services.pdf_service import generate_activity_pdf, generate_resource_pdf
from ..dependencies import get_current_user
from ..services.ldap_service import get_ldap_users

router = APIRouter(tags=["Files"])

# --- STATIC FILES ---
FICHES_PATH = "/app/fiches_pdf"

@router.get("/fiches/list")
def list_fiches():
    if not os.path.exists(FICHES_PATH):
        return []

    fiches = []
    for root, dirs, files in os.walk(FICHES_PATH):
        for file in files:
            if file.endswith(".pdf"):
                rel_path = os.path.relpath(os.path.join(root, file), FICHES_PATH)
                parts = rel_path.split(os.sep)
                sem = parts[0]
                pathway = parts[1] if len(parts) > 2 else "Tronc Commun"
                name = parts[-1]

                fiches.append({
                    "name": name.replace(".pdf", "").replace("_", " "),
                    "filename": name,
                    "semester": sem.replace("semestre_", "S"),
                    "pathway": pathway.replace("_", " "),
                    "url": f"/static/fiches/{rel_path}"
                })
    return fiches

@router.get("/activities/{act_id}/pdf")
def get_activity_pdf(act_id: int, session: Session = Depends(get_session)):
    from sqlalchemy.orm import selectinload
    statement = select(Activity).where(Activity.id == act_id).options(selectinload(Activity.learning_outcomes))
    activity = session.exec(statement).first()
    if not activity: raise HTTPException(status_code=404, detail="Activity not found")
    pdf_buffer = generate_activity_pdf(activity, session)
    filename = f"Fiche_{activity.code.replace(' ', '_')}.pdf"
    return StreamingResponse(pdf_buffer, media_type="application/pdf", headers={"Content-Disposition": f"attachment; filename={filename}"})

@router.get("/resources/{res_id}/pdf")
def get_resource_pdf_file(res_id: int, session: Session = Depends(get_session)):
    from sqlalchemy.orm import selectinload
    statement = select(Resource).where(Resource.id == res_id).options(selectinload(Resource.learning_outcomes))
    resource = session.exec(statement).first()
    if not resource: raise HTTPException(status_code=404, detail="Resource not found")
    pdf_buffer = generate_resource_pdf(resource, session)
    filename = f"Ressource_{resource.code}.pdf"
    return StreamingResponse(pdf_buffer, media_type="application/pdf", headers={"Content-Disposition": f"attachment; filename={filename}"})

@router.get("/export/curriculum")
def export_curriculum(session: Session = Depends(get_session)):
    from sqlalchemy.orm import selectinload
    comps = session.exec(select(Competency).options(selectinload(Competency.essential_components), selectinload(Competency.learning_outcomes))).all()
    acts = session.exec(select(Activity).options(selectinload(Activity.learning_outcomes))).all()
    res = session.exec(select(Resource)).all()
    data = {
        "competencies": [
            {**c.model_dump(),
             "essential_components": [ce.model_dump() for ce in c.essential_components],
             "learning_outcomes": [lo.model_dump() for lo in c.learning_outcomes]}
            for c in comps
        ],
        "activities": [
            {**a.model_dump(),
             "learning_outcomes": [lo.code for lo in a.learning_outcomes]}
            for a in acts
        ],
        "resources": [r.model_dump() for r in res]
    }
    return data

@router.get("/referentiel")
def get_referentiel():
    try:
        with open("apps/api/app/data/referentiel.json", "r") as f: return json.load(f)
    except: return {"parcours": ["Tronc Commun", "BDMRC", "MDEE", "MMPV", "SME", "BI"]}

@router.post("/import/students")
async def import_students(
    file: UploadFile = File(...), 
    year: int = 1,
    formation_type: str = "FI",
    session: Session = Depends(get_session), 
    current_user: str = Depends(get_current_user)
):
    contents = await file.read()
    try:
        if file.filename.endswith('.csv'): df = pd.read_csv(io.BytesIO(contents))
        else: df = pd.read_excel(io.BytesIO(contents))
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Erreur de lecture du fichier: {e}")

    df.columns = [c.lower().strip() for c in df.columns]

    from ..services.ldap_service import get_ldap_user_by_filter
    
    count = 0
    for _, row in df.iterrows():
        # Détection flexible des colonnes d'email
        email1 = str(row.get('mail', row.get('email', ''))).strip().lower()
        email2 = str(row.get('personnel', '')).strip().lower()
        
        # Détection flexible de la colonne de groupe, fallback sur 'Global' si non trouvé
        group_label = str(row.get('groupes', 
                          row.get('groupe', 
                          row.get('promotion', 
                          row.get('tronc commun', ''))))).strip()
        
        if group_label == 'nan' or not group_label:
            group_label = "Global"
        
        if not email1 and not email2: continue

        # Formatage du nom du groupe (ex: Groupe 5 BUT1 FI ou Global BUT1 FI)
        full_group_name = f"{group_label} BUT{year} {formation_type}"

        group = session.exec(select(Group).where(Group.name == full_group_name)).first()
        if not group:
            group = Group(name=full_group_name, year=year, formation_type=formation_type, pathway="Tronc Commun")
            session.add(group); session.commit(); session.refresh(group)

        # Recherche LDAP par email ou UID
        ldap_match = get_ldap_user_by_filter(f'(|(mail={email1})(mail={email2}))')
        if not ldap_match and email1:
            ldap_match = get_ldap_user_by_filter(f'(uid={email1.split("@")[0]})')

        if ldap_match:
            try:
                existing = session.exec(select(User).where(User.ldap_uid == ldap_match['uid'])).first()
                if existing:
                    existing.group_id = group.id
                    existing.role = UserRole.STUDENT
                    existing.email = ldap_match['email']
                    existing.full_name = ldap_match['full_name']
                    session.add(existing)
                else:
                    session.add(User(
                        ldap_uid=ldap_match['uid'], 
                        email=ldap_match['email'], 
                        full_name=ldap_match['full_name'], 
                        role=UserRole.STUDENT, 
                        group_id=group.id
                    ))
                session.commit()
                count += 1
            except Exception as e:
                print(f"Error importing student {ldap_match['uid']}: {e}")
                session.rollback()
                continue

    return {"status": "success", "imported": count}
