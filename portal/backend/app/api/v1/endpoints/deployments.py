"""Deployments API Endpoints"""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Dict, Any

from app.core.database import get_db
from app.core.auth import get_current_user
from app.models.user import User
from app.models.landing_zone import LandingZone, LandingZoneStatus
from app.services.landing_zone_service import LandingZoneService

router = APIRouter()


@router.get("")
async def list_deployments(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    status: str = Query(None, description="Filter by status"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Dict[str, Any]:
    """
    List all deployments.

    - Regular users see only their deployments
    - Approvers and admins see all deployments
    """
    service = LandingZoneService(db)

    filters = {}

    # Filter by user if not admin/approver
    if current_user.role not in ["admin", "approver"]:
        filters["created_by_id"] = current_user.id

    # Filter by status if provided
    if status:
        try:
            status_enum = LandingZoneStatus(status)
            filters["status"] = status_enum
        except ValueError:
            raise HTTPException(status_code=400, detail=f"Invalid status: {status}")

    landing_zones = service.list(
        skip=skip,
        limit=limit,
        filters=filters,
    )

    total = service.count(filters)

    # Format deployment information
    deployments = []
    for lz in landing_zones:
        deployment = {
            "id": lz.id,
            "landing_zone_name": lz.name,
            "status": lz.status.value,
            "deployment_id": lz.deployment_id,
            "deployment_url": lz.deployment_url,
            "deployment_platform": lz.deployment_platform,
            "deployed_at": lz.deployed_at,
            "created_at": lz.created_at,
            "resource_count": lz.resource_count,
        }
        deployments.append(deployment)

    return {
        "items": deployments,
        "total": total,
        "skip": skip,
        "limit": limit,
    }


@router.get("/active")
async def list_active_deployments(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> List[Dict[str, Any]]:
    """
    List currently active deployments (deploying status).
    """
    service = LandingZoneService(db)

    filters = {"status": LandingZoneStatus.DEPLOYING}

    # Filter by user if not admin/approver
    if current_user.role not in ["admin", "approver"]:
        filters["created_by_id"] = current_user.id

    landing_zones = service.list(skip=0, limit=100, filters=filters)

    deployments = []
    for lz in landing_zones:
        deployment = {
            "id": lz.id,
            "landing_zone_name": lz.name,
            "status": lz.status.value,
            "deployment_id": lz.deployment_id,
            "deployment_url": lz.deployment_url,
            "deployment_platform": lz.deployment_platform,
            "deployed_at": lz.deployed_at,
        }
        deployments.append(deployment)

    return deployments


@router.get("/statistics")
async def get_deployment_statistics(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Dict[str, Any]:
    """
    Get deployment statistics.

    Returns counts by status and success rate.
    """
    service = LandingZoneService(db)

    filters = {}
    if current_user.role not in ["admin", "approver"]:
        filters["created_by_id"] = current_user.id

    # Get all landing zones
    all_zones = service.list(skip=0, limit=10000, filters=filters)

    # Count by status
    status_counts = {}
    for lz in all_zones:
        status = lz.status.value
        status_counts[status] = status_counts.get(status, 0) + 1

    # Calculate success rate
    deployed_count = status_counts.get("deployed", 0)
    failed_count = status_counts.get("failed", 0)
    total_completed = deployed_count + failed_count

    success_rate = 0
    if total_completed > 0:
        success_rate = (deployed_count / total_completed) * 100

    return {
        "total_deployments": len(all_zones),
        "status_counts": status_counts,
        "success_rate": round(success_rate, 2),
        "deployed_count": deployed_count,
        "failed_count": failed_count,
        "in_progress_count": status_counts.get("deploying", 0),
    }


@router.get("/{deployment_id}/resources")
async def get_deployment_resources(
    deployment_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Dict[str, Any]:
    """
    Get resources created by a deployment.
    """
    service = LandingZoneService(db)
    landing_zone = service.get(deployment_id)

    if not landing_zone:
        raise HTTPException(status_code=404, detail="Deployment not found")

    # Check permissions
    if (current_user.role not in ["admin", "approver"] and
        landing_zone.created_by_id != current_user.id):
        raise HTTPException(status_code=403, detail="Not authorized")

    return {
        "deployment_id": deployment_id,
        "landing_zone_name": landing_zone.name,
        "resource_count": landing_zone.resource_count,
        "resources": landing_zone.resources or {},
    }
