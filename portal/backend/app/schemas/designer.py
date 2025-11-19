"""Visual IaC Designer Schemas"""

from pydantic import BaseModel, Field
from typing import List, Dict, Any, Optional
from datetime import datetime
from enum import Enum


class ProjectStatus(str, Enum):
    """Project status enum"""
    DRAFT = "draft"
    GENERATING = "generating"
    GENERATED = "generated"
    DEPLOYING = "deploying"
    DEPLOYED = "deployed"
    FAILED = "failed"


class DiagramNode(BaseModel):
    """Diagram node (component)"""
    id: str
    type: str
    position: Dict[str, float]  # {x: 0, y: 0}
    data: Dict[str, Any]  # Component configuration
    style: Optional[Dict[str, Any]] = None


class DiagramEdge(BaseModel):
    """Diagram edge (connection)"""
    id: str
    source: str  # Source node ID
    target: str  # Target node ID
    type: str = "default"
    data: Optional[Dict[str, Any]] = None
    style: Optional[Dict[str, Any]] = None


class DiagramData(BaseModel):
    """Complete diagram data"""
    nodes: List[DiagramNode] = []
    edges: List[DiagramEdge] = []
    viewport: Optional[Dict[str, Any]] = None


class ProjectBase(BaseModel):
    """Base project schema"""
    name: str = Field(..., min_length=1, max_length=200)
    description: Optional[str] = None
    environment: str = "development"
    deployment_platform: str = "spacelift"


class ProjectCreate(ProjectBase):
    """Create project request"""
    diagram: Optional[DiagramData] = None
    configuration: Optional[Dict[str, Any]] = None


class ProjectUpdate(BaseModel):
    """Update project request"""
    name: Optional[str] = Field(None, min_length=1, max_length=200)
    description: Optional[str] = None
    diagram: Optional[DiagramData] = None
    configuration: Optional[Dict[str, Any]] = None
    environment: Optional[str] = None
    deployment_platform: Optional[str] = None


class ProjectResponse(ProjectBase):
    """Project response"""
    id: int
    created_by_id: int
    diagram: Dict[str, Any]
    configuration: Dict[str, Any]
    generated_terraform: Dict[str, Any]
    generated_pipeline: Dict[str, Any]
    status: str
    import_source: Optional[str]
    import_filename: Optional[str]
    landing_zone_id: Optional[int]
    created_at: datetime
    updated_at: Optional[datetime]
    generated_at: Optional[datetime]
    deployed_at: Optional[datetime]

    class Config:
        from_attributes = True


class ProjectList(BaseModel):
    """Paginated project list"""
    items: List[ProjectResponse]
    total: int
    skip: int
    limit: int


class GenerateTerraformRequest(BaseModel):
    """Generate Terraform request"""
    validate: bool = True
    format: bool = True


class GenerateTerraformResponse(BaseModel):
    """Generated Terraform response"""
    files: Dict[str, str]  # filename: content
    validation_errors: List[str] = []
    warnings: List[str] = []


class GeneratePipelineRequest(BaseModel):
    """Generate pipeline request"""
    platform: str = "spacelift"  # spacelift or github_actions


class GeneratePipelineResponse(BaseModel):
    """Generated pipeline response"""
    configuration: Dict[str, Any]
    files: Dict[str, str]  # filename: content


class ComponentTemplateResponse(BaseModel):
    """Component template response"""
    id: int
    type: str
    name: str
    category: str
    icon: Optional[str]
    terraform_module: Optional[str]
    schema: Dict[str, Any]
    default_config: Dict[str, Any]
    ui_config: Dict[str, Any]

    class Config:
        from_attributes = True


class ImportDiagramRequest(BaseModel):
    """Import diagram request"""
    source: str  # lucidchart, drawio, json
    content: str  # Base64 encoded file content or JSON string
    filename: str


class ImportDiagramResponse(BaseModel):
    """Import diagram response"""
    project_id: int
    diagram: DiagramData
    warnings: List[str] = []


class ValidationError(BaseModel):
    """Validation error"""
    node_id: str
    field: str
    message: str
    severity: str = "error"  # error, warning


class ValidationResponse(BaseModel):
    """Validation response"""
    valid: bool
    errors: List[ValidationError] = []
    warnings: List[ValidationError] = []


class DeployRequest(BaseModel):
    """Deploy project request"""
    auto_approve: bool = False
    environment: str = "development"
