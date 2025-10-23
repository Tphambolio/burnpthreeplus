"""Scenario model."""
from datetime import datetime
from sqlalchemy import Column, String, Text, DateTime, ForeignKey, Integer
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
import uuid

from app.db.base import Base


class Scenario(Base):
    """Wildfire scenario model."""

    __tablename__ = "scenarios"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    owner_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)

    # Scenario configuration stored as JSON
    config = Column(JSONB, nullable=False, default=dict)

    # Metadata
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(
        DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False
    )

    # Spatial data references (S3 keys)
    fuel_raster_key = Column(String, nullable=True)
    elevation_raster_key = Column(String, nullable=True)
    ignition_probability_raster_key = Column(String, nullable=True)

    # Simulation parameters
    num_iterations = Column(Integer, default=1000, nullable=False)
    num_ignitions_per_iteration = Column(Integer, default=1, nullable=False)

    # Relationships
    owner = relationship("User", back_populates="scenarios")
    simulation_runs = relationship(
        "SimulationRun", back_populates="scenario", cascade="all, delete-orphan"
    )

    def __repr__(self) -> str:
        return f"<Scenario {self.name} ({self.id})>"
