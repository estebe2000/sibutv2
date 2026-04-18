from fastapi import APIRouter
from app.api.v1.endpoints import auth, dispatch, admin_users

api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(dispatch.router, prefix="/dispatch", tags=["dispatching"])
api_router.include_router(admin_users.router, prefix="/admin/users", tags=["admin-users"])

@api_router.get("/health")
async def health_check():
    return {"status": "ok"}
