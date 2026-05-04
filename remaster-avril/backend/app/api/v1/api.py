from fastapi import APIRouter
from .endpoints import auth, fiches

api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(fiches.router, prefix="/fiches", tags=["fiches"])

@api_router.get("/health")
async def health_check():
    return {"status": "ok"}
