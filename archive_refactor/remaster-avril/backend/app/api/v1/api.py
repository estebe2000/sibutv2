from fastapi import APIRouter
from app.api.v1.endpoints import matrix, ai, admin, dispatch, users

api_router = APIRouter()
api_router.include_router(matrix.router, prefix="/admin")
api_router.include_router(admin.router) # admin.py a déjà le préfixe /admin interne
api_router.include_router(dispatch.router, prefix="/admin")
api_router.include_router(users.router) # users.py n'a pas de préfixe
api_router.include_router(ai.router)
