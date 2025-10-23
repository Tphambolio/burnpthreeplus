"""Scenario endpoints."""
from typing import Any, List
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.db.base import get_db
from app.models.user import User
from app.schemas.scenario import Scenario, ScenarioCreate, ScenarioUpdate
from app.crud.crud_scenario import scenario as scenario_crud
from app.api.deps.auth import get_current_active_user

router = APIRouter()


@router.get("/", response_model=List[Scenario])
def list_scenarios(
    db: Session = Depends(get_db),
    skip: int = 0,
    limit: int = 100,
    current_user: User = Depends(get_current_active_user),
) -> Any:
    """List all scenarios for current user."""
    scenarios = scenario_crud.get_by_owner(
        db, owner_id=current_user.id, skip=skip, limit=limit
    )
    return scenarios


@router.post("/", response_model=Scenario, status_code=status.HTTP_201_CREATED)
def create_scenario(
    *,
    db: Session = Depends(get_db),
    scenario_in: ScenarioCreate,
    current_user: User = Depends(get_current_active_user),
) -> Any:
    """Create new scenario."""
    scenario = scenario_crud.create_with_owner(
        db, obj_in=scenario_in, owner_id=current_user.id
    )
    return scenario


@router.get("/{scenario_id}", response_model=Scenario)
def get_scenario(
    *,
    db: Session = Depends(get_db),
    scenario_id: UUID,
    current_user: User = Depends(get_current_active_user),
) -> Any:
    """Get scenario by ID."""
    scenario = scenario_crud.get(db, id=scenario_id)
    if not scenario:
        raise HTTPException(status_code=404, detail="Scenario not found")

    # Check ownership
    if scenario.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not enough permissions")

    return scenario


@router.put("/{scenario_id}", response_model=Scenario)
def update_scenario(
    *,
    db: Session = Depends(get_db),
    scenario_id: UUID,
    scenario_in: ScenarioUpdate,
    current_user: User = Depends(get_current_active_user),
) -> Any:
    """Update scenario."""
    scenario = scenario_crud.get(db, id=scenario_id)
    if not scenario:
        raise HTTPException(status_code=404, detail="Scenario not found")

    # Check ownership
    if scenario.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not enough permissions")

    scenario = scenario_crud.update(db, db_obj=scenario, obj_in=scenario_in)
    return scenario


@router.delete("/{scenario_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_scenario(
    *,
    db: Session = Depends(get_db),
    scenario_id: UUID,
    current_user: User = Depends(get_current_active_user),
) -> None:
    """Delete scenario."""
    scenario = scenario_crud.get(db, id=scenario_id)
    if not scenario:
        raise HTTPException(status_code=404, detail="Scenario not found")

    # Check ownership
    if scenario.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not enough permissions")

    scenario_crud.remove(db, id=scenario_id)
