"""Landing Zone Database Models"""

from sqlalchemy import (
    Column,
    Integer,
    String,
    Float,
    DateTime,
    ForeignKey,
    Enum as SQLEnum,
    JSON,
    Text,
)
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from enum import Enum

from app.core.database import Base


class LandingZoneStatus(str, Enum):
    """Landing zone status"""
    DRAFT = "draft"
    SUBMITTED = "submitted"
    UNDER_REVIEW = "under_review"
    CHANGES_REQUESTED = "changes_requested"
    APPROVED = "approved"
    REJECTED = "rejected"
    DEPLOYING = "deploying"
    DEPLOYED = "deployed"
    FAILED = "failed"
    DELETING = "deleting"
    DELETED = "deleted"


class LandingZone(Base):
    """Landing Zone model"""

    __tablename__ = "landing_zones"

    # Primary key
    id = Column(Integer, primary_key=True, index=True)

    # Basic info
    name = Column(String(50), unique=True, nullable=False, index=True)
    display_name = Column(String(200), nullable=False)
    description = Column(Text)

    # Type and environment
    landing_zone_type = Column(String(50), nullable=False)  # corp, online, sap
    environment = Column(String(50), nullable=False, index=True)  # production, staging, dev

    # Status
    status = Column(
        SQLEnum(LandingZoneStatus),
        default=LandingZoneStatus.DRAFT,
        nullable=False,
        index=True
    )

    # Azure configuration
    location = Column(String(50), nullable=False)
    address_space = Column(String(20), nullable=False)  # CIDR
    hub_name = Column(String(100), nullable=False)

    # Budget
    monthly_budget = Column(Float)
    current_monthly_cost = Column(Float, default=0.0)

    # Deployment details
    deployment_id = Column(String(200))  # Spacelift stack ID or GitHub workflow run ID
    deployment_url = Column(String(500))  # Link to deployment
    deployment_platform = Column(String(50))  # spacelift or github_actions

    # Metadata
    tags = Column(JSON, default=dict)
    configuration = Column(JSON, default=dict)

    # Resources
    resource_count = Column(Integer, default=0)
    resources = Column(JSON, default=dict)  # Dictionary of created resources

    # Relationships
    created_by_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    created_by = relationship("User", foreign_keys=[created_by_id], back_populates="landing_zones")

    approved_by_id = Column(Integer, ForeignKey("users.id"))
    approved_by = relationship("User", foreign_keys=[approved_by_id])

    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    approved_at = Column(DateTime(timezone=True))
    deployed_at = Column(DateTime(timezone=True))
    deleted_at = Column(DateTime(timezone=True))

    # Comments and approvals
    comments = relationship("LandingZoneComment", back_populates="landing_zone", cascade="all, delete-orphan")
    approvals = relationship("Approval", back_populates="landing_zone", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<LandingZone(id={self.id}, name={self.name}, status={self.status})>"


class LandingZoneComment(Base):
    """Comments on landing zone requests"""

    __tablename__ = "landing_zone_comments"

    id = Column(Integer, primary_key=True, index=True)
    landing_zone_id = Column(Integer, ForeignKey("landing_zones.id"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    comment = Column(Text, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    # Relationships
    landing_zone = relationship("LandingZone", back_populates="comments")
    user = relationship("User")

    def __repr__(self):
        return f"<LandingZoneComment(id={self.id}, landing_zone_id={self.landing_zone_id})>"


class Approval(Base):
    """Approval records"""

    __tablename__ = "approvals"

    id = Column(Integer, primary_key=True, index=True)
    landing_zone_id = Column(Integer, ForeignKey("landing_zones.id"), nullable=False)
    approver_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    status = Column(String(50), nullable=False)  # approved, rejected, pending
    comment = Column(Text)

    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    decided_at = Column(DateTime(timezone=True))

    # Relationships
    landing_zone = relationship("LandingZone", back_populates="approvals")
    approver = relationship("User")

    def __repr__(self):
        return f"<Approval(id={self.id}, status={self.status})>"
