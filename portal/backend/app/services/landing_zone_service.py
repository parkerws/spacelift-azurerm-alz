"""Landing Zone Service - Business Logic"""

from typing import List, Optional, Dict, Any
from sqlalchemy.orm import Session
from sqlalchemy import func
import ipaddress
import logging

from app.models.landing_zone import LandingZone, LandingZoneStatus
from app.schemas.landing_zone import LandingZoneCreate, LandingZoneUpdate

logger = logging.getLogger(__name__)


class LandingZoneService:
    """Service for landing zone operations"""

    def __init__(self, db: Session):
        self.db = db

    def list(
        self,
        skip: int = 0,
        limit: int = 100,
        filters: Optional[Dict[str, Any]] = None,
    ) -> List[LandingZone]:
        """List landing zones with filters"""
        query = self.db.query(LandingZone)

        if filters:
            for key, value in filters.items():
                if hasattr(LandingZone, key):
                    query = query.filter(getattr(LandingZone, key) == value)

        return query.offset(skip).limit(limit).all()

    def count(self, filters: Optional[Dict[str, Any]] = None) -> int:
        """Count landing zones with filters"""
        query = self.db.query(func.count(LandingZone.id))

        if filters:
            for key, value in filters.items():
                if hasattr(LandingZone, key):
                    query = query.filter(getattr(LandingZone, key) == value)

        return query.scalar()

    def get(self, landing_zone_id: int) -> Optional[LandingZone]:
        """Get landing zone by ID"""
        return self.db.query(LandingZone).filter(
            LandingZone.id == landing_zone_id
        ).first()

    def get_by_name(self, name: str) -> Optional[LandingZone]:
        """Get landing zone by name"""
        return self.db.query(LandingZone).filter(
            LandingZone.name == name
        ).first()

    def create(
        self,
        landing_zone_in: LandingZoneCreate,
        user_id: int,
    ) -> LandingZone:
        """Create new landing zone"""
        # Convert Pydantic model to dict
        landing_zone_data = landing_zone_in.model_dump()

        # Convert enums to strings
        landing_zone_data["environment"] = landing_zone_data["environment"].value
        landing_zone_data["landing_zone_type"] = landing_zone_data["landing_zone_type"].value

        # Create database model
        landing_zone = LandingZone(
            **landing_zone_data,
            created_by_id=user_id,
            status=LandingZoneStatus.DRAFT,
        )

        self.db.add(landing_zone)
        self.db.commit()
        self.db.refresh(landing_zone)

        logger.info(
            f"Created landing zone: {landing_zone.name} (ID: {landing_zone.id})"
        )

        return landing_zone

    def update(
        self,
        landing_zone_id: int,
        landing_zone_update: LandingZoneUpdate,
    ) -> Optional[LandingZone]:
        """Update landing zone"""
        landing_zone = self.get(landing_zone_id)
        if not landing_zone:
            return None

        # Update fields
        update_data = landing_zone_update.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(landing_zone, field, value)

        self.db.commit()
        self.db.refresh(landing_zone)

        logger.info(f"Updated landing zone: {landing_zone.name} (ID: {landing_zone.id})")

        return landing_zone

    def delete(self, landing_zone_id: int) -> bool:
        """Delete landing zone"""
        landing_zone = self.get(landing_zone_id)
        if not landing_zone:
            return False

        self.db.delete(landing_zone)
        self.db.commit()

        logger.info(f"Deleted landing zone: {landing_zone.name} (ID: {landing_zone.id})")

        return True

    def submit_for_approval(self, landing_zone_id: int) -> Optional[LandingZone]:
        """Submit landing zone for approval"""
        landing_zone = self.get(landing_zone_id)
        if not landing_zone:
            return None

        landing_zone.status = LandingZoneStatus.SUBMITTED
        self.db.commit()
        self.db.refresh(landing_zone)

        logger.info(
            f"Submitted landing zone for approval: {landing_zone.name} (ID: {landing_zone.id})"
        )

        return landing_zone

    def approve(
        self,
        landing_zone_id: int,
        approver_id: int,
        comment: Optional[str] = None,
    ) -> Optional[LandingZone]:
        """Approve landing zone"""
        from datetime import datetime

        landing_zone = self.get(landing_zone_id)
        if not landing_zone:
            return None

        landing_zone.status = LandingZoneStatus.APPROVED
        landing_zone.approved_by_id = approver_id
        landing_zone.approved_at = datetime.utcnow()

        self.db.commit()
        self.db.refresh(landing_zone)

        logger.info(
            f"Approved landing zone: {landing_zone.name} (ID: {landing_zone.id})"
        )

        return landing_zone

    def reject(
        self,
        landing_zone_id: int,
        approver_id: int,
        comment: Optional[str] = None,
    ) -> Optional[LandingZone]:
        """Reject landing zone"""
        landing_zone = self.get(landing_zone_id)
        if not landing_zone:
            return None

        landing_zone.status = LandingZoneStatus.REJECTED
        landing_zone.approved_by_id = approver_id

        self.db.commit()
        self.db.refresh(landing_zone)

        logger.info(
            f"Rejected landing zone: {landing_zone.name} (ID: {landing_zone.id})"
        )

        return landing_zone

    def request_changes(
        self,
        landing_zone_id: int,
        approver_id: int,
        comment: str,
    ) -> Optional[LandingZone]:
        """Request changes to landing zone"""
        landing_zone = self.get(landing_zone_id)
        if not landing_zone:
            return None

        landing_zone.status = LandingZoneStatus.CHANGES_REQUESTED
        landing_zone.approved_by_id = approver_id

        self.db.commit()
        self.db.refresh(landing_zone)

        logger.info(
            f"Requested changes for landing zone: {landing_zone.name} (ID: {landing_zone.id})"
        )

        return landing_zone

    def check_cidr_overlap(self, cidr: str) -> bool:
        """
        Check if CIDR overlaps with existing landing zones.

        Returns True if overlap detected, False otherwise.
        """
        try:
            new_network = ipaddress.ip_network(cidr)
        except ValueError:
            return False  # Invalid CIDR

        # Get all existing landing zones that are not deleted
        existing_zones = self.db.query(LandingZone).filter(
            LandingZone.status != LandingZoneStatus.DELETED
        ).all()

        for zone in existing_zones:
            try:
                existing_network = ipaddress.ip_network(zone.address_space)

                # Check for overlap
                if new_network.overlaps(existing_network):
                    logger.warning(
                        f"CIDR {cidr} overlaps with existing landing zone: "
                        f"{zone.name} ({zone.address_space})"
                    )
                    return True
            except ValueError:
                # Skip invalid CIDR in database
                continue

        return False

    def update_status(
        self,
        landing_zone_id: int,
        status: LandingZoneStatus,
    ) -> Optional[LandingZone]:
        """Update landing zone status"""
        landing_zone = self.get(landing_zone_id)
        if not landing_zone:
            return None

        landing_zone.status = status
        self.db.commit()
        self.db.refresh(landing_zone)

        logger.info(
            f"Updated landing zone status: {landing_zone.name} (ID: {landing_zone.id}) "
            f"to {status.value}"
        )

        return landing_zone

    def update_deployment_info(
        self,
        landing_zone_id: int,
        deployment_id: str,
        deployment_url: str,
        deployment_platform: str,
    ) -> Optional[LandingZone]:
        """Update deployment information"""
        landing_zone = self.get(landing_zone_id)
        if not landing_zone:
            return None

        landing_zone.deployment_id = deployment_id
        landing_zone.deployment_url = deployment_url
        landing_zone.deployment_platform = deployment_platform

        self.db.commit()
        self.db.refresh(landing_zone)

        logger.info(
            f"Updated deployment info for landing zone: {landing_zone.name} "
            f"(ID: {landing_zone.id})"
        )

        return landing_zone

    def update_resources(
        self,
        landing_zone_id: int,
        resources: Dict[str, Any],
    ) -> Optional[LandingZone]:
        """Update deployed resources"""
        landing_zone = self.get(landing_zone_id)
        if not landing_zone:
            return None

        landing_zone.resources = resources
        landing_zone.resource_count = len(resources)

        self.db.commit()
        self.db.refresh(landing_zone)

        logger.info(
            f"Updated resources for landing zone: {landing_zone.name} "
            f"(ID: {landing_zone.id}), count: {landing_zone.resource_count}"
        )

        return landing_zone
