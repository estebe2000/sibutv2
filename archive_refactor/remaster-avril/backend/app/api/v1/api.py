from fastapi import APIRouter
from app.api.v1.endpoints import matrix, ai, admin

api_router = APIRouter()
api_router.include_router(matrix.router)
api_router.include_router(ai.router)
api_router.include_router(admin.router)
