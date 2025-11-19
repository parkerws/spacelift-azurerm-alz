"""Visual IaC Designer Models"""

from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey, Enum as SQLEnum, JSON
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from enum import Enum

from app.core.database import Base


class ProjectStatus(str, Enum):
    """Project status"""
    DRAFT = "draft"
    GENERATING = "generating"
    GENERATED = "generated"
    DEPLOYING = "deploying"
    DEPLOYED = "deployed"
    FAILED = "failed"


class Project(Base):
    """Visual IaC Designer Project"""

    __tablename__ = "designer_projects"

    # Primary key
    id = Column(Integer, primary_key=True, index=True)

    # Basic info
    name = Column(String(200), nullable=False, index=True)
    description = Column(Text)

    # Ownership
    created_by_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    created_by = relationship("User", foreign_keys=[created_by_id])

    # Diagram data (JSON)
    diagram = Column(JSON, default=dict, nullable=False)
    # nodes: List of diagram nodes
    # edges: List of connections
    # viewport: Current view state

    # Configuration (YAML as JSON)
    configuration = Column(JSON, default=dict)
    # resource configurations
    # overrides
    # pipeline settings

    # Generated output
    generated_terraform = Column(JSON, default=dict)
    # terraform files keyed by filename
    generated_pipeline = Column(JSON, default=dict)
    # pipeline configuration

    # Metadata
    environment = Column(String(50), default="development")
    deployment_platform = Column(String(50), default="spacelift")  # spacelift or github_actions

    # Status
    status = Column(
        SQLEnum(ProjectStatus),
        default=ProjectStatus.DRAFT,
        nullable=False,
        index=True
    )

    # Source tracking
    import_source = Column(String(50))  # lucidchart, drawio, manual
    import_filename = Column(String(255))

    # Deployment tracking
    landing_zone_id = Column(Integer, ForeignKey("landing_zones.id"))
    landing_zone = relationship("LandingZone")

    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    generated_at = Column(DateTime(timezone=True))
    deployed_at = Column(DateTime(timezone=True))

    def __repr__(self):
        return f"<Project(id={self.id}, name={self.name}, status={self.status})>"


class ComponentTemplate(Base):
    """Azure Component Templates for Visual Designer"""

    __tablename__ = "designer_components"

    # Primary key
    id = Column(Integer, primary_key=True, index=True)

    # Component info
    type = Column(String(100), unique=True, nullable=False, index=True)
    name = Column(String(200), nullable=False)
    category = Column(String(50), nullable=False, index=True)  # networking, compute, storage, etc.
    icon = Column(String(50))

    # Module mapping
    terraform_module = Column(String(255))  # Path to Terraform module

    # Schema definition (JSON)
    schema = Column(JSON, nullable=False)
    # inputs: List of input parameters
    # outputs: List of output values
    # connections: Allowed connection types
    # validation: Validation rules

    # Template data
    default_config = Column(JSON, default=dict)
    # Default configuration values

    # Visual properties
    ui_config = Column(JSON, default=dict)
    # width, height, color, icon

    # Metadata
    is_active = Column(Integer, default=1)
    sort_order = Column(Integer, default=0)

    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    def __repr__(self):
        return f"<ComponentTemplate(type={self.type}, name={self.name})>"
