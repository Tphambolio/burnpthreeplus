"""Scenario CRUD operations."""
from typing import List
from uuid import UUID
from sqlalchemy.orm import Session

from app.crud.base import CRUDBase
from app.models.scenario import Scenario
from app.schemas.scenario import ScenarioCreate, ScenarioUpdate


class CRUDScenario(CRUDBase[Scenario, ScenarioCreate, ScenarioUpdate]):
    """CRUD operations for Scenario model."""

    def get_by_owner(
        self, db: Session, *, owner_id: UUID, skip: int = 0, limit: int = 100
    ) -> List[Scenario]:
        """Get scenarios by owner."""
        return (
            db.query(Scenario)
            .filter(Scenario.owner_id == owner_id)
            .offset(skip)
            .limit(limit)
            .all()
        )

    def create_with_owner(
        self, db: Session, *, obj_in: ScenarioCreate, owner_id: UUID
    ) -> Scenario:
        """Create scenario with owner."""
        obj_in_data = obj_in.model_dump()
        db_obj = Scenario(**obj_in_data, owner_id=owner_id)
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj


scenario = CRUDScenario(Scenario)
