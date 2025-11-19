"""Landing Zone Pydantic Schemas"""

from pydantic import BaseModel, Field, validator
from typing import Optional, Dict, Any, List
from datetime import datetime
from enum import Enum


class LandingZoneEnvironment(str, Enum):
    """Environment types"""
    PRODUCTION = "production"
    STAGING = "staging"
    DEVELOPMENT = "development"
    SANDBOX = "sandbox"


class LandingZoneType(str, Enum):
    """Landing zone types"""
    CORP = "corp"
    ONLINE = "online"
    SAP = "sap"
    CUSTOM = "custom"


class LandingZoneBase(BaseModel):
    """Base landing zone schema"""
    name: str = Field(..., min_length=3, max_length=50,
                     description="Unique name for the landing zone")
    display_name: str = Field(..., description="Human-readable display name")
    description: Optional[str] = Field(None, description="Description of purpose")

    environment: LandingZoneEnvironment
    landing_zone_type: LandingZoneType

    # Azure configuration
    location: str = Field(..., description="Azure region (e.g., eastus)")
    address_space: str = Field(..., description="VNet CIDR (e.g., 10.1.0.0/16)")

    # Hub dependency
    hub_name: str = Field(..., description="Hub landing zone to connect to")

    # Budget
    monthly_budget: Optional[float] = Field(
        None, ge=0, description="Monthly budget limit in USD"
    )

    # Additional configuration
    tags: Dict[str, str] = Field(default_factory=dict)
    configuration: Dict[str, Any] = Field(default_factory=dict)

    @validator("address_space")
    def validate_cidr(cls, v):
        """Validate CIDR notation"""
        import ipaddress
        try:
            ipaddress.ip_network(v)
        except ValueError:
            raise ValueError("Invalid CIDR notation")
        return v

    @validator("name")
    def validate_name(cls, v):
        """Validate name format"""
        import re
        if not re.match(r"^[a-z0-9-]+$", v):
            raise ValueError("Name must contain only lowercase letters, numbers, and hyphens")
        return v


class LandingZoneCreate(LandingZoneBase):
    """Schema for creating a landing zone"""
    pass


class LandingZoneUpdate(BaseModel):
    """Schema for updating a landing zone"""
    display_name: Optional[str] = None
    description: Optional[str] = None
    monthly_budget: Optional[float] = None
    tags: Optional[Dict[str, str]] = None
    configuration: Optional[Dict[str, Any]] = None


class LandingZoneResponse(LandingZoneBase):
    """Schema for landing zone responses"""
    id: int
    status: str
    created_at: datetime
    updated_at: datetime
    created_by_id: int
    approved_by_id: Optional[int] = None
    approved_at: Optional[datetime] = None
    deployed_at: Optional[datetime] = None

    # Deployment details
    deployment_id: Optional[str] = None
    deployment_url: Optional[str] = None

    # Cost tracking
    current_monthly_cost: Optional[float] = None

    # Resources
    resource_count: Optional[int] = None

    class Config:
        from_attributes = True


class LandingZoneList(BaseModel):
    """Paginated list of landing zones"""
    items: List[LandingZoneResponse]
    total: int
    skip: int
    limit: int


class LandingZoneStatusResponse(BaseModel):
    """Deployment status response"""
    landing_zone_id: int
    status: str
    deployment_id: Optional[str] = None
    deployment_url: Optional[str] = None

    # Progress
    progress_percentage: Optional[int] = Field(None, ge=0, le=100)
    current_step: Optional[str] = None
    total_steps: Optional[int] = None

    # Timing
    started_at: Optional[datetime] = None
    estimated_completion: Optional[datetime] = None

    # Resources
    resources_created: List[Dict[str, str]] = Field(default_factory=list)

    # Errors
    error_message: Optional[str] = None
    error_details: Optional[Dict[str, Any]] = None
