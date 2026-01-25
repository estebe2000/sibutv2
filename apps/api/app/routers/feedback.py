from fastapi import APIRouter, HTTPException, Depends
from sqlmodel import Session, select
from typing import List, Optional
from ..database import get_session
from ..models import User, UserFeedback, FeedbackType, UserRole
from ..dependencies import get_current_user, require_staff
from datetime import datetime

router = APIRouter(tags=["Feedback"])

@router.get("/", response_model=List[UserFeedback])
async def list_feedback(session: Session = Depends(get_session), current_user: any = Depends(require_staff)):
    # require_staff garantit déjà que ce n'est pas un étudiant
    return session.exec(select(UserFeedback).order_by(UserFeedback.votes.desc(), UserFeedback.created_at.desc())).all()

@router.post("/", response_model=UserFeedback)
async def create_feedback(feedback: UserFeedback, session: Session = Depends(get_session), current_user: any = Depends(require_staff)):
    # Gestion du format dict (admin local) ou objet User
    uid = current_user["ldap_uid"] if isinstance(current_user, dict) else current_user.ldap_uid
    name = current_user["full_name"] if isinstance(current_user, dict) else current_user.full_name
    
    feedback.user_id = uid
    feedback.user_name = name
    feedback.created_at = datetime.now()
    session.add(feedback)
    session.commit()
    session.refresh(feedback)
    return feedback

@router.post("/{feedback_id}/vote")
async def vote_feedback(feedback_id: int, session: Session = Depends(get_session), current_user: any = Depends(require_staff)):
    uid = current_user["ldap_uid"] if isinstance(current_user, dict) else current_user.ldap_uid
    
    fb = session.get(UserFeedback, feedback_id)
    if not fb: raise HTTPException(status_code=404)
    
    voters = fb.voters.split(",") if fb.voters else []
    if uid in voters:
        return {"status": "already_voted", "votes": fb.votes}
    
    voters.append(uid)
    fb.voters = ",".join(voters)
    fb.votes += 1
    session.add(fb)
    session.commit()
    session.refresh(fb)
    return {"status": "success", "votes": fb.votes}

@router.delete("/{feedback_id}")
async def delete_feedback(feedback_id: int, session: Session = Depends(get_session), current_user: any = Depends(require_staff)):
    uid = current_user["ldap_uid"] if isinstance(current_user, dict) else current_user.ldap_uid
    role = current_user["role"] if isinstance(current_user, dict) else current_user.role
    
    fb = session.get(UserFeedback, feedback_id)
    if not fb: raise HTTPException(status_code=404)
    
    is_admin = role in [UserRole.ADMIN, UserRole.SUPER_ADMIN, UserRole.DEPT_HEAD]
    if fb.user_id != uid and not is_admin:
        raise HTTPException(status_code=403)
        
    session.delete(fb)
    session.commit()
    return {"status": "success"}