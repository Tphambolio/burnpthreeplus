"""Main FastAPI application."""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.core.config import settings
from app.api.api import api_router

# Create FastAPI app
app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="BurnP3+ Web Application - Wildfire Burn Probability Modeling",
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    docs_url=f"{settings.API_V1_STR}/docs",
    redoc_url=f"{settings.API_V1_STR}/redoc",
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
async def health_check() -> dict:
    """Health check endpoint."""
    return {
        "status": "healthy",
        "version": settings.VERSION,
        "environment": settings.ENVIRONMENT,
    }


@app.get("/")
async def root() -> dict:
    """Root endpoint."""
    return {
        "message": "BurnP3+ API",
        "version": settings.VERSION,
        "docs": f"{settings.API_V1_STR}/docs",
    }


# Include API router
app.include_router(api_router, prefix=settings.API_V1_STR)


@app.on_event("startup")
async def startup_event() -> None:
    """Startup event handler."""
    # Initialize database connections, etc.
    pass


@app.on_event("shutdown")
async def shutdown_event() -> None:
    """Shutdown event handler."""
    # Clean up resources
    pass
