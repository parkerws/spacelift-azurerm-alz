"""Approvals API Endpoints"""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import Optional

from app.core.database import get_db
from app.core.auth import get_current_user, require_any_role
from app.models.user import User, UserRole
from app.models.landing_zone import LandingZone, LandingZoneStatus
from app.services.landing_zone_service import LandingZoneService
from app.services.deployment_service import DeploymentService
from pydantic import BaseModel

router = APIRouter()


class ApprovalRequest(BaseModel):
    """Approval request schema"""
    comment: Optional[str] = None


@router.get("/pending")
async def list_pending_approvals(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    db: Session = Depends(get_db),
    current_user: User = Depends(require_any_role(UserRole.APPROVER, UserRole.ADMIN)),
):
    """
    List landing zones pending approval.

    Only approvers and admins can access this endpoint.
    """
    service = LandingZoneService(db)

    filters = {
        "status": LandingZoneStatus.SUBMITTED,
    }

    landing_zones = service.list(
        skip=skip,
        limit=limit,
        filters=filters,
    )

    total = service.count(filters)

    return {
        "items": landing_zones,
        "total": total,
        "skip": skip,
        "limit": limit,
    }


@router.post("/{landing_zone_id}/approve")
async def approve_landing_zone(
    landing_zone_id: int,
    approval: ApprovalRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_any_role(UserRole.APPROVER, UserRole.ADMIN)),
):
    """
    Approve a landing zone request.

    This will trigger deployment to the configured platform (Spacelift or GitHub Actions).
    """
    service = LandingZoneService(db)
    landing_zone = service.get(landing_zone_id)

    if not landing_zone:
        raise HTTPException(status_code=404, detail="Landing zone not found")

    # Check if in correct status
    if landing_zone.status != LandingZoneStatus.SUBMITTED:
        raise HTTPException(
            status_code=400,
            detail=f"Cannot approve landing zone in {landing_zone.status} status"
        )

    # Approve the landing zone
    landing_zone = service.approve(
        landing_zone_id=landing_zone_id,
        approver_id=current_user.id,
        comment=approval.comment,
    )

    # Update status to deploying
    service.update_status(landing_zone_id, LandingZoneStatus.DEPLOYING)

    # Trigger deployment
    deployment_service = DeploymentService(db)
    try:
        deployment_info = await deployment_service.trigger_deployment(landing_zone)

        # Update deployment information
        service.update_deployment_info(
            landing_zone_id=landing_zone_id,
            deployment_id=deployment_info["deployment_id"],
            deployment_url=deployment_info["deployment_url"],
            deployment_platform=deployment_info["deployment_platform"],
        )

        return {
            "message": "Landing zone approved and deployment triggered",
            "deployment_url": deployment_info["deployment_url"],
        }

    except Exception as e:
        # Mark as failed
        service.update_status(landing_zone_id, LandingZoneStatus.FAILED)
        raise HTTPException(
            status_code=500,
            detail=f"Deployment trigger failed: {str(e)}"
        )


@router.post("/{landing_zone_id}/reject")
async def reject_landing_zone(
    landing_zone_id: int,
    approval: ApprovalRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_any_role(UserRole.APPROVER, UserRole.ADMIN)),
):
    """Reject a landing zone request"""
    service = LandingZoneService(db)
    landing_zone = service.get(landing_zone_id)

    if not landing_zone:
        raise HTTPException(status_code=404, detail="Landing zone not found")

    # Check if in correct status
    if landing_zone.status != LandingZoneStatus.SUBMITTED:
        raise HTTPException(
            status_code=400,
            detail=f"Cannot reject landing zone in {landing_zone.status} status"
        )

    # Reject the landing zone
    landing_zone = service.reject(
        landing_zone_id=landing_zone_id,
        approver_id=current_user.id,
        comment=approval.comment,
    )

    # TODO: Send notification to requester

    return {
        "message": "Landing zone rejected",
        "landing_zone": landing_zone,
    }


@router.post("/{landing_zone_id}/request-changes")
async def request_changes(
    landing_zone_id: int,
    approval: ApprovalRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_any_role(UserRole.APPROVER, UserRole.ADMIN)),
):
    """Request changes to a landing zone"""
    if not approval.comment:
        raise HTTPException(
            status_code=400,
            detail="Comment is required when requesting changes"
        )

    service = LandingZoneService(db)
    landing_zone = service.get(landing_zone_id)

    if not landing_zone:
        raise HTTPException(status_code=404, detail="Landing zone not found")

    # Check if in correct status
    if landing_zone.status != LandingZoneStatus.SUBMITTED:
        raise HTTPException(
            status_code=400,
            detail=f"Cannot request changes for landing zone in {landing_zone.status} status"
        )

    # Request changes
    landing_zone = service.request_changes(
        landing_zone_id=landing_zone_id,
        approver_id=current_user.id,
        comment=approval.comment,
    )

    # TODO: Send notification to requester

    return {
        "message": "Changes requested",
        "landing_zone": landing_zone,
    }
