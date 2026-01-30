from fastapi import Header, Depends, HTTPException
from sqlmodel import Session, select
from .database import get_session
from .models import Department

async def get_current_department(
    x_department_id: str = Header(None, alias="X-Department-ID"),
    session: Session = Depends(get_session)
) -> Department:
    """
    Dependency to retrieve the current department context from the header.
    Defaults to the first department if not specified (legacy support).
    """
    if x_department_id:
        dept = session.get(Department, int(x_department_id))
        if not dept:
            raise HTTPException(status_code=404, detail="Department not found")
        return dept

    # Default to TC or first available
    first_dept = session.exec(select(Department)).first()
    if not first_dept:
        # Should not happen after migration
        raise HTTPException(status_code=500, detail="No department configured")
    return first_dept
