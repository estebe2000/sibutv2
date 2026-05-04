from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import Response
from sqlmodel import Session, select
from typing import Any
import jwt

from ....infrastructure.database import get_session
from ....infrastructure.services.pdf_service import ReportLabPdfGenerator
from ....models.activity import Activity
from ....models.curriculum import Resource
from .auth import oauth2_scheme

router = APIRouter()
pdf_generator = ReportLabPdfGenerator()

def get_current_user_name(token: str = Depends(oauth2_scheme)) -> str:
    try:
        decoded = jwt.decode(token, options={"verify_signature": False})
        return decoded.get("name", decoded.get("preferred_username", "Utilisateur Inconnu"))
    except Exception:
        return "Utilisateur Inconnu"

@router.get("/activities/{activity_id}/pdf")
async def get_activity_pdf(
    activity_id: int,
    db: Session = Depends(get_session),
    requestor_name: str = Depends(get_current_user_name)
):
    activity = db.exec(select(Activity).where(Activity.id == activity_id)).first()
    if not activity:
        raise HTTPException(status_code=404, detail="Activity not found")

    pdf_bytes = pdf_generator.generate_fiche_pdf(
        item_data=activity.model_dump(),
        requestor_name=requestor_name
    )

    return Response(content=pdf_bytes, media_type="application/pdf", headers={"Content-Disposition": f'attachment; filename="fiche_activity_{activity.code}.pdf"'})

@router.get("/resources/{resource_id}/pdf")
async def get_resource_pdf(
    resource_id: int,
    db: Session = Depends(get_session),
    requestor_name: str = Depends(get_current_user_name)
):
    resource = db.exec(select(Resource).where(Resource.id == resource_id)).first()
    if not resource:
        raise HTTPException(status_code=404, detail="Resource not found")

    pdf_bytes = pdf_generator.generate_fiche_pdf(
        item_data=resource.model_dump(),
        requestor_name=requestor_name
    )

    return Response(content=pdf_bytes, media_type="application/pdf", headers={"Content-Disposition": f'attachment; filename="fiche_resource_{resource.code}.pdf"'})
