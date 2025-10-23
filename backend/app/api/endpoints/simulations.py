"""Simulation endpoints."""
from typing import Any, List
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.db.base import get_db
from app.models.user import User
from app.schemas.simulation import SimulationRun, SimulationRunCreate
from app.crud.crud_simulation import simulation_run as simulation_crud
from app.crud.crud_scenario import scenario as scenario_crud
from app.api.deps.auth import get_current_active_user

router = APIRouter()


@router.get("/", response_model=List[SimulationRun])
def list_simulations(
    db: Session = Depends(get_db),
    scenario_id: UUID = None,
    skip: int = 0,
    limit: int = 100,
    current_user: User = Depends(get_current_active_user),
) -> Any:
    """List simulation runs, optionally filtered by scenario."""
    if scenario_id:
        # Verify scenario ownership
        scenario = scenario_crud.get(db, id=scenario_id)
        if not scenario or scenario.owner_id != current_user.id:
            raise HTTPException(status_code=403, detail="Not enough permissions")

        simulations = simulation_crud.get_by_scenario(
            db, scenario_id=scenario_id, skip=skip, limit=limit
        )
    else:
        # Get all simulations for user's scenarios
        simulations = simulation_crud.get_multi(db, skip=skip, limit=limit)

    return simulations


@router.post("/", response_model=SimulationRun, status_code=status.HTTP_201_CREATED)
def create_simulation(
    *,
    db: Session = Depends(get_db),
    simulation_in: SimulationRunCreate,
    current_user: User = Depends(get_current_active_user),
) -> Any:
    """Create and start a new simulation run."""
    # Verify scenario ownership
    scenario = scenario_crud.get(db, id=simulation_in.scenario_id)
    if not scenario:
        raise HTTPException(status_code=404, detail="Scenario not found")

    if scenario.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not enough permissions")

    # Create simulation run
    simulation = simulation_crud.create(db, obj_in=simulation_in)

    # TODO: Queue Celery task to start the simulation pipeline

    return simulation


@router.get("/{simulation_id}", response_model=SimulationRun)
def get_simulation(
    *,
    db: Session = Depends(get_db),
    simulation_id: UUID,
    current_user: User = Depends(get_current_active_user),
) -> Any:
    """Get simulation run by ID."""
    simulation = simulation_crud.get(db, id=simulation_id)
    if not simulation:
        raise HTTPException(status_code=404, detail="Simulation not found")

    # Verify ownership through scenario
    scenario = scenario_crud.get(db, id=simulation.scenario_id)
    if not scenario or scenario.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not enough permissions")

    return simulation


@router.delete("/{simulation_id}", status_code=status.HTTP_204_NO_CONTENT)
def cancel_simulation(
    *,
    db: Session = Depends(get_db),
    simulation_id: UUID,
    current_user: User = Depends(get_current_active_user),
) -> None:
    """Cancel a running simulation."""
    simulation = simulation_crud.get(db, id=simulation_id)
    if not simulation:
        raise HTTPException(status_code=404, detail="Simulation not found")

    # Verify ownership
    scenario = scenario_crud.get(db, id=simulation.scenario_id)
    if not scenario or scenario.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not enough permissions")

    # TODO: Cancel Celery task
    # TODO: Update simulation status to cancelled

    simulation_crud.remove(db, id=simulation_id)
