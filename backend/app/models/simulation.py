"""Simulation run models."""
from datetime import datetime
from enum import Enum
from sqlalchemy import Column, String, Text, DateTime, ForeignKey, Integer, Float, Enum as SQLEnum
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
from geoalchemy2 import Geometry
import uuid

from app.db.base import Base


class SimulationStatus(str, Enum):
    """Simulation run status."""

    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"


class FireGrowthModel(str, Enum):
    """Fire growth model types."""

    CELL2FIRE = "cell2fire"
    PROMETHEUS = "prometheus"
    FIRESTARR = "firestarr"


class SimulationRun(Base):
    """Simulation run model."""

    __tablename__ = "simulation_runs"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    scenario_id = Column(UUID(as_uuid=True), ForeignKey("scenarios.id"), nullable=False)

    # Status tracking
    status = Column(
        SQLEnum(SimulationStatus), default=SimulationStatus.PENDING, nullable=False
    )
    fire_growth_model = Column(
        SQLEnum(FireGrowthModel), default=FireGrowthModel.CELL2FIRE, nullable=False
    )

    # Progress tracking
    current_stage = Column(Integer, default=1, nullable=False)  # 1-4
    progress_percentage = Column(Float, default=0.0, nullable=False)

    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    started_at = Column(DateTime, nullable=True)
    completed_at = Column(DateTime, nullable=True)

    # Results metadata
    results_key = Column(String, nullable=True)  # S3 key for burn probability raster
    summary_statistics = Column(JSONB, nullable=True)  # Aggregated stats

    # Error tracking
    error_message = Column(Text, nullable=True)

    # Celery task tracking
    celery_task_id = Column(String, nullable=True, unique=True)

    # Relationships
    scenario = relationship("Scenario", back_populates="simulation_runs")
    ignitions = relationship(
        "Ignition", back_populates="simulation_run", cascade="all, delete-orphan"
    )

    def __repr__(self) -> str:
        return f"<SimulationRun {self.id} - {self.status.value}>"


class Ignition(Base):
    """Ignition point model (Stage 1 output)."""

    __tablename__ = "ignitions"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    simulation_run_id = Column(
        UUID(as_uuid=True), ForeignKey("simulation_runs.id"), nullable=False
    )

    # Monte Carlo iteration number
    iteration = Column(Integer, nullable=False)

    # Spatial location (PostGIS point)
    point = Column(Geometry("POINT", srid=4326), nullable=False)

    # Temporal attributes
    julian_day = Column(Integer, nullable=True)  # Day of year (1-365)
    hour = Column(Integer, nullable=True)  # Hour of day (0-23)

    # Burning conditions (Stage 2 output)
    temperature = Column(Float, nullable=True)  # Celsius
    wind_speed = Column(Float, nullable=True)  # km/h
    wind_direction = Column(Float, nullable=True)  # Degrees
    relative_humidity = Column(Float, nullable=True)  # Percentage

    # Fire Weather Index components
    ffmc = Column(Float, nullable=True)  # Fine Fuel Moisture Code
    dmc = Column(Float, nullable=True)  # Duff Moisture Code
    dc = Column(Float, nullable=True)  # Drought Code
    isi = Column(Float, nullable=True)  # Initial Spread Index
    bui = Column(Float, nullable=True)  # Build Up Index
    fwi = Column(Float, nullable=True)  # Fire Weather Index

    # Fire growth results (Stage 3 output) - stored as JSON
    fire_perimeter = Column(JSONB, nullable=True)  # GeoJSON polygon
    fire_metrics = Column(JSONB, nullable=True)  # Rate of spread, intensity, etc.

    # Relationships
    simulation_run = relationship("SimulationRun", back_populates="ignitions")

    def __repr__(self) -> str:
        return f"<Ignition {self.id} - Iteration {self.iteration}>"
