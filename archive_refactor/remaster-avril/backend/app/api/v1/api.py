from fastapi import APIRouter
from app.api.v1.endpoints import matrix, ai, admin, dispatch, users

api_router = APIRouter()
api_router.include_router(matrix.router)
api_router.include_router(ai.router)
api_router.include_router(admin.router)
api_router.include_router(dispatch.router)
api_router.include_router(users.router)
