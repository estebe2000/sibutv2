from fastapi import APIRouter, Request, Depends, HTTPException
from sqlmodel import Session, select, func
from app.core.security import admin_only, get_current_db_user, engine
from app.models.models import Announcement, User, Promotion, Group
from app.services.matrix_service import matrix_service
import uuid

router = APIRouter(prefix="/matrix", tags=["matrix"])

@router.post("/announce", dependencies=[Depends(admin_only)])
async def api_matrix_announce(request: Request, user: User = Depends(get_current_db_user)):
    data = await request.json()
    title = data.get("title")
    content = data.get("content")
    room_type = data.get("room", "general")
    priority = data.get("priority", "normal")
    
    room_id, event_id = await matrix_service.broadcast_announcement(title, content, room_type, priority)
    
    if event_id:
        with Session(engine) as session:
            ann = Announcement(
                title=title, 
                content=content, 
                author_uid=user.ldap_uid, 
                matrix_event_id=event_id, 
                matrix_room_id=room_id
            )
            session.add(ann)
            session.commit()
        return {"status": "success", "event_id": event_id}
    raise HTTPException(status_code=500, detail="Échec de l'envoi Matrix")

@router.post("/sync-rooms", dependencies=[Depends(admin_only)])
async def api_matrix_sync_rooms():
    created = 0
    with Session(engine) as session:
        promos = session.exec(select(Promotion)).all()
        for p in promos:
            room_name = f"BUT TC - Promo {p.entry_year}"
            room_id = await matrix_service.create_room(room_name, topic=f"Salon officiel de la promo {p.entry_year}")
            if room_id: created += 1
            
        groups = session.exec(select(Group)).all()
        for g in groups:
            room_id = await matrix_service.create_room(f"Groupe {g.name}", topic=f"Travaux dirigés - {g.name}")
            if room_id: created += 1
            
    return {"status": "success", "created": created}

@router.delete("/announcements/{id}", dependencies=[Depends(admin_only)])
async def api_matrix_delete_announcement(id: int):
    with Session(engine) as session:
        ann = session.get(Announcement, id)
        if ann:
            if ann.matrix_event_id and ann.matrix_room_id:
                await matrix_service.redact_event(ann.matrix_room_id, ann.matrix_event_id)
            session.delete(ann)
            session.commit()
            return {"status": "success"}
    raise HTTPException(status_code=404, detail="Annonce non trouvée")
