from fastapi import APIRouter, HTTPException, Depends
from sqlmodel import Session, select
from typing import List, Optional
from ..database import get_session
from ..models import User, UserFeedback, FeedbackType, UserRole
from ..dependencies import get_current_user
from datetime import datetime

router = APIRouter(tags=["Feedback"])

@router.get("/", response_model=List[UserFeedback])
async def list_feedback(session: Session = Depends(get_session), current_user: User = Depends(get_current_user)):
    if current_user.role == UserRole.STUDENT:
        raise HTTPException(status_code=403, detail="Réservé au personnel")
    return session.exec(select(UserFeedback).order_by(UserFeedback.votes.desc(), UserFeedback.created_at.desc())).all()

@router.post("/", response_model=UserFeedback)
async def create_feedback(feedback: UserFeedback, session: Session = Depends(get_session), current_user: User = Depends(get_current_user)):
    if current_user.role == UserRole.STUDENT:
        raise HTTPException(status_code=403)
    feedback.user_id = current_user.ldap_uid
    feedback.user_name = current_user.full_name
    feedback.created_at = datetime.now()
    session.add(feedback)
    session.commit()
    session.refresh(feedback)
    return feedback

@router.post("/{feedback_id}/vote")
async def vote_feedback(feedback_id: int, session: Session = Depends(get_session), current_user: User = Depends(get_current_user)):
    if current_user.role == UserRole.STUDENT:
        raise HTTPException(status_code=403)
    
    fb = session.get(UserFeedback, feedback_id)
    if not fb: raise HTTPException(status_code=404)
    
    voters = fb.voters.split(",") if fb.voters else []
    if current_user.ldap_uid in voters:
        return {"status": "already_voted", "votes": fb.votes}
    
    voters.append(current_user.ldap_uid)
    fb.voters = ",".join(voters)
    fb.votes += 1
    session.add(fb)
    session.commit()
    session.refresh(fb)
    return {"status": "success", "votes": fb.votes}

@router.delete("/{feedback_id}")
async def delete_feedback(feedback_id: int, session: Session = Depends(get_session), current_user: User = Depends(get_current_user)):
    fb = session.get(UserFeedback, feedback_id)
    if not fb: raise HTTPException(status_code=404)
    
    # Seul l'auteur ou un admin peut supprimer
    is_admin = current_user.role in ["ADMIN", "SUPER_ADMIN", "DEPT_HEAD"]
    if fb.user_id != current_user.ldap_uid and not is_admin:
        raise HTTPException(status_code=403)
        
    session.delete(fb)
    session.commit()
    return {"status": "success"}
