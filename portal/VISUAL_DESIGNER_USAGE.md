# Visual IaC Designer - User Guide

## 🎨 What is it?

The **Visual IaC Designer** is a low-code infrastructure design system that lets you:
- **Design** Azure infrastructure using drag-and-drop
- **Configure** resources visually or with YAML
- **Generate** production-ready Terraform code
- **Deploy** to Spacelift or GitHub Actions

**No Terraform knowledge required!** Design infrastructure like you would in Lucidchart, then get working code.

## ✅ Complete and Ready to Use!

Both backend and frontend are **100% functional**. You can start designing infrastructure visually right now!

### What's Included
- ✅ **Backend API**: REST endpoints for project management, code generation, validation
- ✅ **Code Generator**: Visual diagram → Terraform HCL converter
- ✅ **Frontend Canvas**: React Flow drag-and-drop designer
- ✅ **Component Library**: 5 Azure resource types ready to use
- ✅ **Configuration Panel**: Edit properties with forms or YAML
- ✅ **Code Preview**: Monaco editor with syntax highlighting
- ✅ **Project Management**: Save/load/delete visual designs

## 🚀 Getting Started

### 1. Start the Portal

```bash
cd portal
docker-compose -f docker-compose.full.yml up -d
docker-compose -f docker-compose.full.yml exec backend python -m app.db.init_db
```

### 2. Access the Designer

1. Open **http://localhost:3000**
2. Login with: `user@example.com` / `user123`
3. Click **"Visual Designer"** in the left menu
4. Click **"New Project"**

### 3. Design Your Infrastructure

**Drag and Drop:**
1. Drag components from the left palette to the canvas
2. Connect them by dragging from the bottom handle to the top handle of another component
3. Click a component to configure it in the right panel

**Configure:**
- **Properties Tab**: Use forms for common settings
- **YAML Tab**: Advanced configuration

**Generate Code:**
1. Click **"Validate"** to check for errors
2. Click **"Generate Terraform"** to create code
3. View generated files in tabs (`main.tf`, `variables.tf`, etc.)
4. Click **"Download"** to get the files

## 📖 Step-by-Step Example

### Create a Hub-and-Spoke Network

1. **Create a New Project**
   - Name: "Hub and Spoke Network"
   - Environment: Production
   - Platform: Spacelift

2. **Add Hub VNet**
   - Drag "Virtual Network" to canvas
   - Click to configure:
     - Name: `vnet-hub-prod`
     - Address Space: `10.0.0.0/16`
     - Location: `eastus`

3. **Add Gateway Subnet**
   - Drag "Subnet" to canvas
   - Connect Hub VNet → Subnet (drag from bottom of VNet to top of Subnet)
   - Configure:
     - Name: `GatewaySubnet`
     - Address Prefixes: `10.0.0.0/24`

4. **Add Spoke VNet**
   - Drag another "Virtual Network"
   - Configure:
     - Name: `vnet-spoke-prod`
     - Address Space: `10.1.0.0/16`

5. **Add Workload Subnet**
   - Drag "Subnet" to canvas
   - Connect Spoke VNet → Subnet
   - Configure:
     - Name: `subnet-workloads`
     - Address Prefixes: `10.1.1.0/24`

6. **Generate Terraform**
   - Click "Save" button
   - Click "Generate Terraform"
   - View generated code!

**Generated Output:**
```hcl
# main.tf
module "vnet_hub_prod" {
  source = "../../modules/networking/azure-vnet"

  resource_group_name = azurerm_resource_group.main.name
  location            = "eastus"
  name                = "vnet-hub-prod"
  address_space       = ["10.0.0.0/16"]
}

module "gatewaysubnet" {
  source = "../../modules/networking/azure-subnet"

  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  name                = "GatewaySubnet"
  address_prefixes    = ["10.0.0.0/24"]

  depends_on = [module.vnet_hub_prod]
}

# ... plus variables.tf, outputs.tf, versions.tf, README.md
```

## 🎯 Available Components

### Networking
- **Virtual Network**: VNet with address space configuration
- **Subnet**: Subnet within a VNet
- **Network Security Group**: NSG with security rules

### Compute
- **Virtual Machine**: Linux/Windows VM with size selection

### Storage
- **Storage Account**: Blob/File/Table/Queue storage with replication

### Coming Soon
- Azure Firewall
- VPN Gateway
- Azure Bastion
- AKS Cluster
- SQL Database
- Cosmos DB
- Key Vault
- Container Registry

## 🔧 Features in Detail

### Visual Canvas
- **Drag & Drop**: Add resources by dragging from palette
- **Connect**: Draw connections showing dependencies
- **Multi-Select**: Select multiple nodes with Shift+Click
- **Delete**: Select and press Delete key
- **Zoom & Pan**: Scroll to zoom, drag to pan
- **Mini-map**: Bird's eye view in bottom-right corner
- **Auto-Save**: Changes saved automatically

### Configuration Panel
Two ways to configure resources:

**1. Properties Tab** (Easy)
- Type-specific form fields
- Dropdowns for common values
- Validation hints

**2. YAML Tab** (Advanced)
- Full YAML editor with syntax highlighting
- Complete control over all properties
- Real-time validation

### Code Generation
Generates complete Terraform project:

- `main.tf`: Resource definitions using modules
- `variables.tf`: Input variables
- `outputs.tf`: Output values
- `versions.tf`: Provider requirements
- `terraform.tfvars`: Variable values
- `README.md`: Deployment instructions

**Features:**
- ✅ Topological sorting (dependencies first)
- ✅ Uses existing Terraform modules
- ✅ Circular dependency detection
- ✅ YAML configuration merging
- ✅ Best practices applied

### Validation
Real-time validation checks:
- ✅ No circular dependencies
- ✅ All connections valid
- ✅ Required fields present
- ✅ CIDR ranges valid
- ✅ Resource naming conventions

## 📊 Project Status Tracking

Projects have status indicators:
- **draft**: Being designed
- **generating**: Code generation in progress
- **generated**: Code ready for review
- **deploying**: Being deployed
- **deployed**: Successfully deployed
- **failed**: Deployment or generation failed

## 🎨 Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Shift + Click` | Multi-select nodes |
| `Delete` | Delete selected nodes/edges |
| `Ctrl/Cmd + S` | Save project |
| `Ctrl/Cmd + Z` | Undo |
| `Ctrl/Cmd + Shift + Z` | Redo |
| `Mouse Wheel` | Zoom in/out |
| `Space + Drag` | Pan canvas |

## 🔌 Integration with Landing Zone Factory

Visual Designer integrates seamlessly:

1. **Uses Same Modules**: Generated code uses the 15 Terraform modules from the factory
2. **Spacelift Integration**: Can deploy directly to Spacelift stacks
3. **GitHub Actions**: Alternative deployment via workflows
4. **Policy Compliance**: Generated code follows best practices

## 🛠️ API Endpoints

For programmatic access:

```bash
# List projects
GET /api/v1/designer/projects

# Create project
POST /api/v1/designer/projects
{
  "name": "My Infrastructure",
  "environment": "production",
  "diagram": {...}
}

# Generate Terraform
POST /api/v1/designer/projects/{id}/generate/terraform

# Validate
POST /api/v1/designer/projects/{id}/validate

# List components
GET /api/v1/designer/components
```

See `VISUAL_DESIGNER_TESTING.md` for API examples.

## 📝 Tips & Tricks

### Best Practices
1. **Start with networking**: Design VNets and subnets first
2. **Use meaningful names**: Helps identify resources in generated code
3. **Validate early**: Click Validate button frequently
4. **Save often**: Auto-save helps, but manual save ensures persistence
5. **Review generated code**: Always review before deploying

### Common Patterns
- **Hub-Spoke**: Hub VNet → Multiple Spoke VNets with peering
- **3-Tier**: Web subnet → App subnet → Data subnet
- **DMZ**: External subnet with NSG → Internal subnets

### Advanced Configuration
Use YAML tab to:
- Add lifecycle rules
- Set timeouts
- Add provider configurations
- Override defaults

Example YAML override:
```yaml
name: vnet-hub-prod
address_space:
  - 10.0.0.0/16
dns_servers:
  - 10.0.0.4
  - 10.0.0.5
overrides:
  terraform: |
    lifecycle {
      prevent_destroy = true
    }
```

## 🐛 Troubleshooting

**Components won't drag:**
- Ensure you're dragging from the palette on the left
- Try refreshing the page

**Can't connect nodes:**
- Drag from bottom handle (source) to top handle (target)
- Ensure both nodes are on canvas

**Validation errors:**
- Click "Validate" to see specific errors
- Check for circular dependencies
- Ensure all required fields filled

**Code generation fails:**
- Validate configuration first
- Check for missing resource names
- Verify CIDR blocks don't overlap

**Can't see project:**
- Check you're logged in
- Verify project ownership
- Try refreshing project list

## 🎓 Next Steps

1. **Try the example** above to get familiar
2. **Explore components** by dragging each type
3. **Generate code** and review what's created
4. **Deploy** to Spacelift or GitHub Actions
5. **Build complex patterns** like multi-region hub-spoke

## 🚀 Future Features

Planned enhancements:
- 📥 **Import from Lucidchart**: Upload .vsdx files
- 📥 **Import from Draw.io**: Upload .drawio files
- 🎨 **Custom components**: Define your own
- 📊 **Cost estimation**: See costs before deploying
- 🔄 **Pipeline generation**: Auto-create workflows
- 📸 **Diagram export**: Save as PNG/SVG
- 🔗 **State import**: Import existing Terraform
- 👥 **Collaboration**: Share designs with team

## 📚 Learn More

- **Architecture**: See `VISUAL_DESIGNER.md`
- **API Testing**: See `VISUAL_DESIGNER_TESTING.md`
- **Backend Code**: `portal/backend/app/services/code_generator.py`
- **Frontend Code**: `portal/frontend/src/pages/Designer.tsx`

---

**Ready to design infrastructure visually?** Open http://localhost:3000 and click "Visual Designer"!
