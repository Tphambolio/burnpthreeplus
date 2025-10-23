"""Scenario schemas."""
from datetime import datetime
from typing import Optional, Dict, Any
from pydantic import BaseModel, UUID4


class ScenarioBase(BaseModel):
    """Base scenario schema."""

    name: str
    description: Optional[str] = None
    config: Dict[str, Any] = {}
    num_iterations: int = 1000
    num_ignitions_per_iteration: int = 1


class ScenarioCreate(ScenarioBase):
    """Scenario creation schema."""

    pass


class ScenarioUpdate(BaseModel):
    """Scenario update schema."""

    name: Optional[str] = None
    description: Optional[str] = None
    config: Optional[Dict[str, Any]] = None
    num_iterations: Optional[int] = None
    num_ignitions_per_iteration: Optional[int] = None
    fuel_raster_key: Optional[str] = None
    elevation_raster_key: Optional[str] = None
    ignition_probability_raster_key: Optional[str] = None


class Scenario(ScenarioBase):
    """Scenario response schema."""

    id: UUID4
    owner_id: UUID4
    fuel_raster_key: Optional[str] = None
    elevation_raster_key: Optional[str] = None
    ignition_probability_raster_key: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
