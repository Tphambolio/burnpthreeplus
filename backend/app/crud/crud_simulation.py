"""Simulation CRUD operations."""
from typing import List
from uuid import UUID
from sqlalchemy.orm import Session

from app.crud.base import CRUDBase
from app.models.simulation import SimulationRun
from app.schemas.simulation import SimulationRunCreate


class CRUDSimulationRun(CRUDBase[SimulationRun, SimulationRunCreate, dict]):
    """CRUD operations for SimulationRun model."""

    def get_by_scenario(
        self, db: Session, *, scenario_id: UUID, skip: int = 0, limit: int = 100
    ) -> List[SimulationRun]:
        """Get simulation runs by scenario."""
        return (
            db.query(SimulationRun)
            .filter(SimulationRun.scenario_id == scenario_id)
            .offset(skip)
            .limit(limit)
            .all()
        )

    def create(self, db: Session, *, obj_in: SimulationRunCreate) -> SimulationRun:
        """Create simulation run."""
        obj_in_data = obj_in.model_dump()
        db_obj = SimulationRun(**obj_in_data)
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj


simulation_run = CRUDSimulationRun(SimulationRun)
