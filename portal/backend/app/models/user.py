"""User Database Model"""

from sqlalchemy import Column, Integer, String, Boolean, DateTime, Enum as SQLEnum
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from enum import Enum

from app.core.database import Base


class UserRole(str, Enum):
    """User roles"""
    USER = "user"  # Regular user, can create landing zone requests
    APPROVER = "approver"  # Can approve landing zone requests
    ADMIN = "admin"  # Full access


class User(Base):
    """User model"""

    __tablename__ = "users"

    # Primary key
    id = Column(Integer, primary_key=True, index=True)

    # Authentication
    email = Column(String(255), unique=True, nullable=False, index=True)
    username = Column(String(100), unique=True, nullable=False, index=True)
    hashed_password = Column(String(255))  # Optional if using OAuth

    # Profile
    full_name = Column(String(200))
    department = Column(String(100))

    # Role
    role = Column(
        SQLEnum(UserRole),
        default=UserRole.USER,
        nullable=False,
        index=True
    )

    # OAuth
    azure_ad_oid = Column(String(255), unique=True)  # Azure AD Object ID
    github_id = Column(String(255), unique=True)  # GitHub User ID

    # Status
    is_active = Column(Boolean, default=True, nullable=False)
    is_verified = Column(Boolean, default=False, nullable=False)

    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    last_login = Column(DateTime(timezone=True))

    # Relationships
    landing_zones = relationship(
        "LandingZone",
        foreign_keys="LandingZone.created_by_id",
        back_populates="created_by"
    )

    def __repr__(self):
        return f"<User(id={self.id}, email={self.email}, role={self.role})>"
