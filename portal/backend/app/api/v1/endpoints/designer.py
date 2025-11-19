"""Visual IaC Designer API Endpoints"""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
import logging
import base64
import json

from app.core.database import get_db
from app.core.auth import get_current_user
from app.models.user import User
from app.models.designer import Project, ProjectStatus, ComponentTemplate
from app.schemas.designer import (
    ProjectCreate,
    ProjectUpdate,
    ProjectResponse,
    ProjectList,
    GenerateTerraformRequest,
    GenerateTerraformResponse,
    GeneratePipelineRequest,
    GeneratePipelineResponse,
    ComponentTemplateResponse,
    ImportDiagramRequest,
    ImportDiagramResponse,
    ValidationResponse,
    ValidationError,
)
from app.services.code_generator import CodeGeneratorService

router = APIRouter()
logger = logging.getLogger(__name__)


@router.get("/projects", response_model=ProjectList)
async def list_projects(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    status: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """List visual designer projects"""
    query = db.query(Project)

    # Filter by user (non-admins see only their projects)
    if current_user.role not in ["admin", "approver"]:
        query = query.filter(Project.created_by_id == current_user.id)

    # Filter by status
    if status:
        query = query.filter(Project.status == status)

    # Get total count
    total = query.count()

    # Get projects
    projects = query.order_by(Project.updated_at.desc()).offset(skip).limit(limit).all()

    return {
        "items": projects,
        "total": total,
        "skip": skip,
        "limit": limit,
    }


@router.post("/projects", response_model=ProjectResponse)
async def create_project(
    project_in: ProjectCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Create a new visual designer project"""
    # Check for duplicate name
    existing = (
        db.query(Project)
        .filter(Project.name == project_in.name, Project.created_by_id == current_user.id)
        .first()
    )

    if existing:
        raise HTTPException(status_code=400, detail="Project with this name already exists")

    # Create project
    project = Project(
        name=project_in.name,
        description=project_in.description,
        environment=project_in.environment,
        deployment_platform=project_in.deployment_platform,
        created_by_id=current_user.id,
        diagram=project_in.diagram.dict() if project_in.diagram else {"nodes": [], "edges": []},
        configuration=project_in.configuration or {},
        status=ProjectStatus.DRAFT,
    )

    db.add(project)
    db.commit()
    db.refresh(project)

    logger.info(f"Created project: {project.name} (ID: {project.id})")

    return project


@router.get("/projects/{project_id}", response_model=ProjectResponse)
async def get_project(
    project_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get a project by ID"""
    project = db.query(Project).filter(Project.id == project_id).first()

    if not project:
        raise HTTPException(status_code=404, detail="Project not found")

    # Check permissions
    if current_user.role not in ["admin", "approver"] and project.created_by_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized")

    return project


@router.patch("/projects/{project_id}", response_model=ProjectResponse)
async def update_project(
    project_id: int,
    project_update: ProjectUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Update a project"""
    project = db.query(Project).filter(Project.id == project_id).first()

    if not project:
        raise HTTPException(status_code=404, detail="Project not found")

    # Check permissions
    if current_user.role not in ["admin"] and project.created_by_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized")

    # Update fields
    update_data = project_update.dict(exclude_unset=True)
    for field, value in update_data.items():
        if field == "diagram" and value:
            setattr(project, field, value.dict() if hasattr(value, "dict") else value)
        else:
            setattr(project, field, value)

    db.commit()
    db.refresh(project)

    logger.info(f"Updated project: {project.name} (ID: {project.id})")

    return project


@router.delete("/projects/{project_id}")
async def delete_project(
    project_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Delete a project"""
    project = db.query(Project).filter(Project.id == project_id).first()

    if not project:
        raise HTTPException(status_code=404, detail="Project not found")

    # Check permissions
    if current_user.role not in ["admin"] and project.created_by_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized")

    db.delete(project)
    db.commit()

    logger.info(f"Deleted project: {project.name} (ID: {project.id})")

    return {"message": "Project deleted successfully"}


@router.post("/projects/{project_id}/generate/terraform", response_model=GenerateTerraformResponse)
async def generate_terraform(
    project_id: int,
    request: GenerateTerraformRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Generate Terraform code from visual diagram"""
    project = db.query(Project).filter(Project.id == project_id).first()

    if not project:
        raise HTTPException(status_code=404, detail="Project not found")

    # Check permissions
    if current_user.role not in ["admin", "approver"] and project.created_by_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized")

    try:
        # Update status
        project.status = ProjectStatus.GENERATING
        db.commit()

        # Generate Terraform code
        generator = CodeGeneratorService()

        # Validate if requested
        if request.validate:
            is_valid, errors, warnings = generator.validate(project.diagram, project.configuration)

            if not is_valid:
                project.status = ProjectStatus.DRAFT
                db.commit()

                return {
                    "files": {},
                    "validation_errors": [e["message"] for e in errors],
                    "warnings": [w["message"] for w in warnings],
                }

        # Generate code
        files = generator.generate_terraform(
            diagram=project.diagram,
            configuration=project.configuration,
            project_name=project.name,
        )

        # Save generated code
        project.generated_terraform = files
        project.status = ProjectStatus.GENERATED
        from datetime import datetime
        project.generated_at = datetime.utcnow()
        db.commit()

        logger.info(f"Generated Terraform for project: {project.name} (ID: {project.id})")

        return {
            "files": files,
            "validation_errors": [],
            "warnings": [],
        }

    except Exception as e:
        logger.error(f"Failed to generate Terraform: {e}", exc_info=True)
        project.status = ProjectStatus.FAILED
        db.commit()
        raise HTTPException(status_code=500, detail=f"Generation failed: {str(e)}")


@router.post("/projects/{project_id}/validate", response_model=ValidationResponse)
async def validate_project(
    project_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Validate project configuration"""
    project = db.query(Project).filter(Project.id == project_id).first()

    if not project:
        raise HTTPException(status_code=404, detail="Project not found")

    # Check permissions
    if current_user.role not in ["admin", "approver"] and project.created_by_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized")

    generator = CodeGeneratorService()
    is_valid, errors, warnings = generator.validate(project.diagram, project.configuration)

    return {
        "valid": is_valid,
        "errors": errors,
        "warnings": warnings,
    }


@router.get("/components", response_model=List[ComponentTemplateResponse])
async def list_components(
    category: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """List available component templates"""
    query = db.query(ComponentTemplate).filter(ComponentTemplate.is_active == 1)

    if category:
        query = query.filter(ComponentTemplate.category == category)

    components = query.order_by(ComponentTemplate.sort_order, ComponentTemplate.name).all()

    # If no components in DB, return default set
    if not components:
        return _get_default_components()

    return components


def _get_default_components():
    """Return default component set"""
    return [
        {
            "id": 1,
            "type": "azure-vnet",
            "name": "Virtual Network",
            "category": "networking",
            "icon": "network",
            "terraform_module": "../../modules/networking/azure-vnet",
            "schema": {
                "inputs": [
                    {"name": "name", "type": "string", "required": True},
                    {"name": "address_space", "type": "list(string)", "required": True},
                    {"name": "location", "type": "string", "required": True},
                ]
            },
            "default_config": {
                "address_space": ["10.0.0.0/16"],
            },
            "ui_config": {
                "width": 200,
                "height": 100,
                "color": "#0078d4",
            },
        },
        {
            "id": 2,
            "type": "azure-subnet",
            "name": "Subnet",
            "category": "networking",
            "icon": "subnet",
            "terraform_module": "../../modules/networking/azure-subnet",
            "schema": {
                "inputs": [
                    {"name": "name", "type": "string", "required": True},
                    {"name": "address_prefixes", "type": "list(string)", "required": True},
                ]
            },
            "default_config": {
                "address_prefixes": ["10.0.1.0/24"],
            },
            "ui_config": {
                "width": 150,
                "height": 75,
                "color": "#50a0e6",
            },
        },
        {
            "id": 3,
            "type": "azure-nsg",
            "name": "Network Security Group",
            "category": "networking",
            "icon": "security",
            "terraform_module": "../../modules/networking/azure-nsg",
            "schema": {
                "inputs": [
                    {"name": "name", "type": "string", "required": True},
                ]
            },
            "default_config": {},
            "ui_config": {
                "width": 150,
                "height": 75,
                "color": "#107c10",
            },
        },
        {
            "id": 4,
            "type": "azure-vm",
            "name": "Virtual Machine",
            "category": "compute",
            "icon": "computer",
            "terraform_module": "../../modules/compute/azure-vm",
            "schema": {
                "inputs": [
                    {"name": "name", "type": "string", "required": True},
                    {"name": "size", "type": "string", "required": True},
                ]
            },
            "default_config": {
                "size": "Standard_B2s",
            },
            "ui_config": {
                "width": 150,
                "height": 100,
                "color": "#8661c5",
            },
        },
        {
            "id": 5,
            "type": "azure-storage",
            "name": "Storage Account",
            "category": "storage",
            "icon": "storage",
            "terraform_module": "../../modules/shared-services/azure-storage-account",
            "schema": {
                "inputs": [
                    {"name": "name", "type": "string", "required": True},
                    {"name": "account_tier", "type": "string", "required": True},
                ]
            },
            "default_config": {
                "account_tier": "Standard",
                "account_replication_type": "LRS",
            },
            "ui_config": {
                "width": 150,
                "height": 75,
                "color": "#ff8c00",
            },
        },
    ]


@router.get("/components/{component_type}", response_model=ComponentTemplateResponse)
async def get_component(
    component_type: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get a specific component template"""
    component = (
        db.query(ComponentTemplate)
        .filter(ComponentTemplate.type == component_type, ComponentTemplate.is_active == 1)
        .first()
    )

    if not component:
        # Return from defaults
        defaults = _get_default_components()
        for comp in defaults:
            if comp["type"] == component_type:
                return comp

        raise HTTPException(status_code=404, detail="Component not found")

    return component
