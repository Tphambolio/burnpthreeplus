"""API router aggregation."""
from fastapi import APIRouter

from app.api.endpoints import auth, scenarios, simulations

api_router = APIRouter()

# Include endpoint routers
api_router.include_router(auth.router, prefix="/auth", tags=["authentication"])
api_router.include_router(scenarios.router, prefix="/scenarios", tags=["scenarios"])
api_router.include_router(simulations.router, prefix="/simulations", tags=["simulations"])

# Health check
@api_router.get("/health")
async def health_check():
    """API health check."""
    return {"status": "ok", "message": "BurnP3+ API is running"}
