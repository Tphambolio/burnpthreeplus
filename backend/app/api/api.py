"""API router aggregation."""
from fastapi import APIRouter

# from app.api.endpoints import auth, scenarios, spatial, simulations

api_router = APIRouter()

# Include endpoint routers
# api_router.include_router(auth.router, prefix="/auth", tags=["authentication"])
# api_router.include_router(scenarios.router, prefix="/scenarios", tags=["scenarios"])
# api_router.include_router(spatial.router, prefix="/spatial", tags=["spatial"])
# api_router.include_router(simulations.router, prefix="/simulations", tags=["simulations"])

# Placeholder endpoint
@api_router.get("/status")
async def api_status():
    """API status endpoint."""
    return {"status": "ok", "message": "API is running"}
