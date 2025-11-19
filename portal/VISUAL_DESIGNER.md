# Visual IaC Designer - Architecture

## Overview

The Visual IaC Designer is a low-code infrastructure design system that allows users to:
- **Design** infrastructure visually using drag-and-drop
- **Import** diagrams from Lucidchart, Draw.io, or other tools
- **Generate** production-ready Terraform modules and pipeline definitions
- **Configure** resources using YAML for custom overrides
- **Deploy** directly to Spacelift or GitHub Actions

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Visual IaC Designer                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │   Canvas     │  │  Component   │  │    YAML      │    │
│  │   Editor     │  │   Library    │  │   Config     │    │
│  │ (React Flow) │  │  (Palette)   │  │   Editor     │    │
│  └──────────────┘  └──────────────┘  └──────────────┘    │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │  Lucidchart  │  │  Validation  │  │    Code      │    │
│  │   Import     │  │    Engine    │  │  Generator   │    │
│  └──────────────┘  └──────────────┘  └──────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      Backend API                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │   Diagram    │  │  Terraform   │  │   Pipeline   │    │
│  │   Storage    │  │  Generator   │  │  Generator   │    │
│  └──────────────┘  └──────────────┘  └──────────────┘    │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │   Parser     │  │  Validator   │  │    Module    │    │
│  │   Engine     │  │   Engine     │  │   Library    │    │
│  └──────────────┘  └──────────────┘  └──────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   Output Generation                         │
├─────────────────────────────────────────────────────────────┤
│  • Terraform Modules (.tf files)                           │
│  • Variable Files (.tfvars)                                │
│  • Spacelift Stack Definitions                             │
│  • GitHub Actions Workflows                                │
│  • Documentation (README.md)                               │
└─────────────────────────────────────────────────────────────┘
```

## Components

### 1. Visual Canvas (Frontend)
**Technology:** React Flow + TypeScript + Material-UI

**Features:**
- Drag-and-drop Azure resource components
- Connection lines showing relationships (peering, dependencies)
- Grid snapping and alignment tools
- Zoom, pan, minimap
- Multi-select and bulk operations
- Undo/redo history

**Component Types:**
- **Networking:** VNet, Subnet, NSG, Route Table, VPN Gateway, Firewall
- **Compute:** Virtual Machine, VMSS, AKS, Container Instances
- **Storage:** Storage Account, Disk, File Share
- **Database:** SQL Database, Cosmos DB, PostgreSQL
- **Security:** Key Vault, Managed Identity
- **Monitoring:** Log Analytics, Application Insights
- **Containers:** Container Registry, AKS, App Service

### 2. Component Library
**Component Schema:**
```yaml
id: azure-vnet
name: Virtual Network
category: networking
icon: network
terraform_module: modules/networking/azure-vnet
inputs:
  - name: address_space
    type: cidr
    required: true
    validation: cidr_validator
  - name: location
    type: string
    required: true
outputs:
  - name: vnet_id
    description: Virtual Network resource ID
connections:
  - type: peering
    target: azure-vnet
  - type: contains
    target: azure-subnet
```

### 3. Lucidchart/Draw.io Import
**Supported Formats:**
- `.vsdx` (Lucidchart export)
- `.drawio` (Draw.io XML)
- `.xml` (Generic diagram)
- `.json` (Custom format)

**Import Process:**
1. Parse diagram file
2. Identify shapes and their types
3. Map shapes to Azure resource components
4. Extract connections and relationships
5. Generate initial configuration
6. Present for user review and refinement

### 4. Code Generation Engine
**Input:** Visual diagram + YAML configurations
**Output:** Complete Terraform infrastructure

**Generation Process:**
```
Visual Diagram
    ↓
Dependency Analysis (topological sort)
    ↓
Module Selection (map to existing modules)
    ↓
Configuration Merge (visual + YAML overrides)
    ↓
Terraform HCL Generation
    ↓
Validation & Formatting
    ↓
Output: .tf files
```

**Example Output:**
```hcl
# Generated from Visual IaC Designer
# Project: my-landing-zone
# Generated: 2025-11-19

module "vnet_hub" {
  source = "../../modules/networking/azure-vnet"

  name                = "vnet-hub-prod"
  resource_group_name = azurerm_resource_group.main.name
  location            = "eastus"
  address_space       = ["10.0.0.0/16"]

  tags = var.common_tags
}

module "subnet_gateway" {
  source = "../../modules/networking/azure-subnet"

  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = module.vnet_hub.name
  address_prefixes     = ["10.0.0.0/24"]
}
```

### 5. YAML Configuration Editor
**Purpose:** Allow users to override and customize generated code

**Example YAML:**
```yaml
# my-landing-zone.yaml
project:
  name: my-landing-zone
  description: Production landing zone for app team
  environment: production

resources:
  vnet_hub:
    type: azure-vnet
    position: {x: 100, y: 100}
    config:
      name: vnet-hub-prod
      address_space: ["10.0.0.0/16"]
      location: eastus
      dns_servers: ["10.0.0.4", "10.0.0.5"]
    overrides:
      # Custom Terraform overrides
      terraform: |
        lifecycle {
          prevent_destroy = true
        }

  subnet_gateway:
    type: azure-subnet
    position: {x: 150, y: 200}
    parent: vnet_hub
    config:
      name: GatewaySubnet
      address_prefixes: ["10.0.0.0/24"]

connections:
  - from: vnet_hub
    to: vnet_spoke
    type: peering
    config:
      allow_gateway_transit: true
```

### 6. Pipeline Definition Generator
**Generates:**
- Spacelift stack definitions
- GitHub Actions workflows
- Stack dependencies
- Environment configurations

**Example Spacelift Output:**
```yaml
# Generated Spacelift stack
stacks:
  - name: my-landing-zone-hub
    space: landing-zones/production
    repository: infrastructure
    branch: main
    project_root: projects/my-landing-zone
    terraform_version: "1.8.0"
    administrative: false
    autodeploy: false
    dependencies:
      - my-landing-zone-prereqs
    environment:
      - name: TF_VAR_environment
        value: production
```

## Data Models

### Project
```python
class Project(Base):
    id: int
    name: str
    description: str
    created_by_id: int
    diagram: dict  # JSON representation
    configuration: dict  # YAML configuration
    generated_code: dict  # Generated Terraform
    status: ProjectStatus
    created_at: datetime
    updated_at: datetime
```

### Diagram Node
```python
class DiagramNode:
    id: str
    type: str  # Component type
    position: dict  # {x, y}
    data: dict  # Component configuration
    style: dict  # Visual styling
```

### Diagram Edge
```python
class DiagramEdge:
    id: str
    source: str  # Source node ID
    target: str  # Target node ID
    type: str  # Connection type (peering, dependency, etc.)
    data: dict  # Connection configuration
```

## API Endpoints

### Projects
- `POST /api/v1/designer/projects` - Create new project
- `GET /api/v1/designer/projects` - List projects
- `GET /api/v1/designer/projects/{id}` - Get project
- `PATCH /api/v1/designer/projects/{id}` - Update project
- `DELETE /api/v1/designer/projects/{id}` - Delete project

### Diagram Operations
- `POST /api/v1/designer/projects/{id}/diagram` - Update diagram
- `GET /api/v1/designer/projects/{id}/diagram` - Get diagram

### Import/Export
- `POST /api/v1/designer/import/lucidchart` - Import Lucidchart
- `POST /api/v1/designer/import/drawio` - Import Draw.io
- `GET /api/v1/designer/export/{id}/terraform` - Export Terraform
- `GET /api/v1/designer/export/{id}/pipeline` - Export pipeline

### Code Generation
- `POST /api/v1/designer/generate/{id}/terraform` - Generate Terraform
- `POST /api/v1/designer/generate/{id}/pipeline` - Generate pipeline
- `POST /api/v1/designer/validate/{id}` - Validate configuration

### Components
- `GET /api/v1/designer/components` - List available components
- `GET /api/v1/designer/components/{type}` - Get component schema

## User Workflow

### 1. Create New Project
```
User → New Project → Visual Designer
  ↓
Drag components from library → Configure → Connect
  ↓
Add YAML overrides (optional) → Validate
  ↓
Generate Terraform → Review → Save
```

### 2. Import from Lucidchart
```
User → Import → Upload .vsdx
  ↓
Parse diagram → Map to Azure components
  ↓
Review mappings → Adjust configurations
  ↓
Generate code → Deploy
```

### 3. Generate and Deploy
```
Visual Design + YAML Config
  ↓
Generate Terraform + Pipeline
  ↓
Create PR or Spacelift Stack
  ↓
Review → Approve → Deploy
```

## Benefits

1. **Accessibility:** Non-technical teams can design infrastructure
2. **Speed:** Visual design is faster than writing code
3. **Validation:** Real-time validation prevents errors
4. **Best Practices:** Built-in modules ensure consistency
5. **Documentation:** Visual diagrams serve as documentation
6. **Flexibility:** YAML overrides for advanced customization
7. **Integration:** Works with existing landing zone factory

## Technology Stack

### Frontend
- React 18 + TypeScript
- React Flow (visual canvas)
- Monaco Editor (YAML editing)
- Material-UI components
- Axios for API calls

### Backend
- FastAPI (Python)
- SQLAlchemy (database)
- Jinja2 (template generation)
- PyYAML (YAML parsing)
- NetworkX (dependency analysis)

### Storage
- PostgreSQL (project storage)
- File storage (generated code)

## Next Steps

1. ✅ Architecture design
2. Create backend API models and endpoints
3. Build React Flow visual designer
4. Implement component library
5. Create Terraform generator
6. Add import parsers
7. Build pipeline generator
8. Integration testing
