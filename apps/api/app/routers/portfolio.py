from fastapi import APIRouter, HTTPException, Depends
from sqlmodel import Session, select
from typing import List, Optional
from ..database import get_session
from ..models import User, PortfolioPage
from ..dependencies import get_current_user
from datetime import datetime

router = APIRouter(tags=["Portfolio"])

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
