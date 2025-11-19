"""Landing Zones API Endpoints"""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional

from app.core.database import get_db
from app.core.auth import get_current_user
from app.models.user import User
from app.models.landing_zone import LandingZone, LandingZoneStatus
from app.schemas.landing_zone import (
    LandingZoneCreate,
    LandingZoneUpdate,
    LandingZoneResponse,
    LandingZoneList,
)
from app.services.landing_zone_service import LandingZoneService
from app.services.deployment_service import DeploymentService

router = APIRouter()


@router.get("", response_model=LandingZoneList)
async def list_landing_zones(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    environment: Optional[str] = None,
    status: Optional[LandingZoneStatus] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    List landing zones.

    - Regular users see only their own landing zones
    - Approvers and admins see all landing zones
    """
    service = LandingZoneService(db)

    filters = {}
    if environment:
        filters["environment"] = environment
    if status:
        filters["status"] = status

    # Filter by user if not admin
    if current_user.role not in ["admin", "approver"]:
        filters["created_by_id"] = current_user.id

    landing_zones = service.list(
        skip=skip,
        limit=limit,
        filters=filters
    )

    total = service.count(filters)

    return {
        "items": landing_zones,
        "total": total,
        "skip": skip,
        "limit": limit,
    }


@router.post("", response_model=LandingZoneResponse, status_code=201)
async def create_landing_zone(
    landing_zone_in: LandingZoneCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Create a new landing zone request.

    The request will be in 'draft' status and require approval before deployment.
    """
    service = LandingZoneService(db)

    # Validate CIDR doesn't overlap
    if service.check_cidr_overlap(landing_zone_in.address_space):
        raise HTTPException(
            status_code=400,
            detail="Address space overlaps with existing landing zone"
        )

    # Create landing zone
    landing_zone = service.create(landing_zone_in, current_user.id)

    return landing_zone


@router.get("/{landing_zone_id}", response_model=LandingZoneResponse)
async def get_landing_zone(
    landing_zone_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get landing zone details"""
    service = LandingZoneService(db)
    landing_zone = service.get(landing_zone_id)

    if not landing_zone:
        raise HTTPException(status_code=404, detail="Landing zone not found")

    # Check permissions
    if (current_user.role not in ["admin", "approver"] and
        landing_zone.created_by_id != current_user.id):
        raise HTTPException(status_code=403, detail="Not authorized")

    return landing_zone


@router.patch("/{landing_zone_id}", response_model=LandingZoneResponse)
async def update_landing_zone(
    landing_zone_id: int,
    landing_zone_update: LandingZoneUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Update landing zone (only in draft or changes_requested status)"""
    service = LandingZoneService(db)
    landing_zone = service.get(landing_zone_id)

    if not landing_zone:
        raise HTTPException(status_code=404, detail="Landing zone not found")

    # Check permissions
    if (current_user.role not in ["admin"] and
        landing_zone.created_by_id != current_user.id):
        raise HTTPException(status_code=403, detail="Not authorized")

    # Can only update in certain statuses
    if landing_zone.status not in [LandingZoneStatus.DRAFT, LandingZoneStatus.CHANGES_REQUESTED]:
        raise HTTPException(
            status_code=400,
            detail=f"Cannot update landing zone in {landing_zone.status} status"
        )

    updated_landing_zone = service.update(landing_zone_id, landing_zone_update)
    return updated_landing_zone


@router.post("/{landing_zone_id}/submit", response_model=LandingZoneResponse)
async def submit_landing_zone(
    landing_zone_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Submit landing zone for approval"""
    service = LandingZoneService(db)
    landing_zone = service.get(landing_zone_id)

    if not landing_zone:
        raise HTTPException(status_code=404, detail="Landing zone not found")

    # Check permissions
    if landing_zone.created_by_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized")

    # Submit for approval
    landing_zone = service.submit_for_approval(landing_zone_id)

    # TODO: Send notification to approvers

    return landing_zone


@router.delete("/{landing_zone_id}")
async def delete_landing_zone(
    landing_zone_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Delete landing zone (only in draft or failed status)"""
    service = LandingZoneService(db)
    landing_zone = service.get(landing_zone_id)

    if not landing_zone:
        raise HTTPException(status_code=404, detail="Landing zone not found")

    # Check permissions
    if (current_user.role not in ["admin"] and
        landing_zone.created_by_id != current_user.id):
        raise HTTPException(status_code=403, detail="Not authorized")

    # Can only delete in certain statuses
    if landing_zone.status not in [
        LandingZoneStatus.DRAFT,
        LandingZoneStatus.FAILED,
        LandingZoneStatus.REJECTED
    ]:
        raise HTTPException(
            status_code=400,
            detail=f"Cannot delete landing zone in {landing_zone.status} status"
        )

    service.delete(landing_zone_id)

    return {"message": "Landing zone deleted successfully"}


@router.get("/{landing_zone_id}/status")
async def get_deployment_status(
    landing_zone_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get real-time deployment status"""
    service = LandingZoneService(db)
    landing_zone = service.get(landing_zone_id)

    if not landing_zone:
        raise HTTPException(status_code=404, detail="Landing zone not found")

    # Check permissions
    if (current_user.role not in ["admin", "approver"] and
        landing_zone.created_by_id != current_user.id):
        raise HTTPException(status_code=403, detail="Not authorized")

    # Get deployment status from Spacelift or GitHub Actions
    deployment_service = DeploymentService(db)
    status = await deployment_service.get_deployment_status(landing_zone)

    return status


@router.get("/{landing_zone_id}/logs")
async def get_deployment_logs(
    landing_zone_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get deployment logs"""
    service = LandingZoneService(db)
    landing_zone = service.get(landing_zone_id)

    if not landing_zone:
        raise HTTPException(status_code=404, detail="Landing zone not found")

    # Check permissions
    if (current_user.role not in ["admin", "approver"] and
        landing_zone.created_by_id != current_user.id):
        raise HTTPException(status_code=403, detail="Not authorized")

    # Get logs from deployment platform
    deployment_service = DeploymentService(db)
    logs = await deployment_service.get_deployment_logs(landing_zone)

    return {"logs": logs}


@router.post("/{landing_zone_id}/retry")
async def retry_deployment(
    landing_zone_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Retry failed deployment"""
    service = LandingZoneService(db)
    landing_zone = service.get(landing_zone_id)

    if not landing_zone:
        raise HTTPException(status_code=404, detail="Landing zone not found")

    # Check permissions
    if current_user.role not in ["admin", "approver"]:
        raise HTTPException(status_code=403, detail="Not authorized")

    # Can only retry failed deployments
    if landing_zone.status != LandingZoneStatus.FAILED:
        raise HTTPException(
            status_code=400,
            detail="Can only retry failed deployments"
        )

    # Trigger deployment retry
    deployment_service = DeploymentService(db)
    await deployment_service.retry_deployment(landing_zone)

    return {"message": "Deployment retry initiated"}
