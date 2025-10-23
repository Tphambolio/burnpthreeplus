"""Simulation schemas."""
from datetime import datetime
from typing import Optional, Dict, Any
from pydantic import BaseModel, UUID4
from enum import Enum


class SimulationStatus(str, Enum):
    """Simulation status enum."""

    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"


class FireGrowthModel(str, Enum):
    """Fire growth model enum."""

    CELL2FIRE = "cell2fire"
    PROMETHEUS = "prometheus"
    FIRESTARR = "firestarr"


class SimulationRunCreate(BaseModel):
    """Simulation run creation schema."""

    scenario_id: UUID4
    fire_growth_model: FireGrowthModel = FireGrowthModel.CELL2FIRE


class SimulationRun(BaseModel):
    """Simulation run response schema."""

    id: UUID4
    scenario_id: UUID4
    status: SimulationStatus
    fire_growth_model: FireGrowthModel
    current_stage: int
    progress_percentage: float
    created_at: datetime
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    results_key: Optional[str] = None
    summary_statistics: Optional[Dict[str, Any]] = None
    error_message: Optional[str] = None

    class Config:
        from_attributes = True
