# Spacelift Azure Landing Zone Factory

A comprehensive Spacelift factory for Azure landing zones with full automation for environment setup, space structure, policies, module registry, and hub-and-spoke networking patterns.

## Architecture

This factory implements the Azure Landing Zone hub-and-spoke architecture pattern with Spacelift-native automation:

```
Management Groups
├── Platform
│   ├── Connectivity (Hub)
│   │   ├── Azure Firewall
│   │   ├── VPN Gateway
│   │   ├── Azure Bastion
│   │   └── DDoS Protection
│   ├── Management
│   │   ├── Log Analytics
│   │   └── Azure Monitor
│   └── Identity
└── Landing Zones (Spokes)
    ├── Corp
    └── Online
```

## Repository Structure

```
.
├── bootstrapper/          # Spacelift environment bootstrapper
│   ├── spaces/           # Space hierarchy setup
│   ├── service-principals/  # Azure SP configuration
│   └── contexts/         # Spacelift contexts
├── modules/              # Terraform modules (Spacelift Module Registry)
│   ├── networking/       # Priority 1: Foundation networking
│   │   ├── azure-vnet/
│   │   ├── azure-subnet/
│   │   ├── azure-nsg/
│   │   └── azure-route-table/
│   ├── hub/              # Priority 2: Hub networking
│   │   ├── azure-firewall/
│   │   ├── azure-vpn-gateway/
│   │   ├── azure-bastion/
│   │   └── azure-vnet-peering/
│   ├── shared-services/  # Priority 3: Shared services
│   │   ├── azure-log-analytics/
│   │   ├── azure-key-vault/
│   │   ├── azure-container-registry/
│   │   └── azure-storage-account/
│   └── management/       # Priority 4: Management
│       ├── azure-management-group/
│       ├── azure-policy-assignment/
│       └── azure-rbac/
├── policies/             # Spacelift policies
│   ├── plan/            # Terraform plan policies (cost, compliance)
│   ├── approval/        # Approval policies for production
│   ├── push/            # Automated deployment policies
│   └── trigger/         # Stack dependency policies
├── stack-factory/       # Hub-and-spoke stack templates
│   ├── hub/             # Hub stack configuration
│   ├── spoke/           # Spoke stack templates
│   └── admin/           # Administrative stack for factory
└── cli/                 # Stack generator CLI tool
```

## Features

### 🚀 Environment Bootstrapper
- Automated Spacelift space hierarchy creation
- Azure service principal setup with least-privilege permissions
- Context and integration configuration

### 📋 Policy Library
- **Plan Policies**: Cost controls, compliance checks, security validation
- **Approval Policies**: Production deployment safeguards
- **Push Policies**: Automated deployment triggers
- **Trigger Policies**: Stack dependency orchestration

### 📦 Module Registry
15 production-ready Azure modules with comprehensive tests:
- **Networking Foundation**: VNet, Subnet, NSG, Route Tables
- **Hub Networking**: Firewall, VPN Gateway, Bastion, Peering
- **Shared Services**: Log Analytics, Key Vault, ACR, Storage
- **Management**: Management Groups, Policy Assignment, RBAC

### 🏗️ Stack Factory
- Dynamic stack creation using Spacelift Terraform provider
- Hub-and-spoke topology automation
- Automatic dependency management (hub provisioned before spokes)
- Naming convention enforcement

### 🛠️ Stack Generator CLI
- Interactive stack scaffolding
- Template-based configuration
- Automatic Spacelift registration
- Git repository integration

## Quick Start

### Prerequisites

- Terraform >= 1.9.0 or OpenTofu >= 1.8.0
- Azure subscription with Owner permissions
- Spacelift account
- Git

### 1. Bootstrap Spacelift Environment

```bash
cd bootstrapper
terraform init
terraform plan
terraform apply
```

### 2. Deploy Stack Factory

```bash
cd stack-factory/admin
terraform init
terraform apply
```

### 3. Create a Landing Zone

```bash
./cli/stack-generator create-spoke \
  --name "corp-prod" \
  --environment "production" \
  --cidr "10.1.0.0/16"
```

## Module Usage

Each module is self-contained with examples and tests. Example:

```hcl
module "vnet" {
  source = "./modules/networking/azure-vnet"

  name                = "vnet-hub-eastus-001"
  resource_group_name = azurerm_resource_group.hub.name
  location            = "eastus"
  address_space       = ["10.0.0.0/16"]

  ddos_protection_plan = {
    id     = azurerm_network_ddos_protection_plan.hub.id
    enable = true
  }

  tags = local.tags
}
```

## Spacelift Integration

### Module Registry
All modules include `.spacelift/config.yml` for automatic registration in Spacelift's module registry.

### Stack Dependencies
The stack factory automatically configures dependencies:
```
Hub Stack → Spoke Stacks → Workload Stacks
```

### Policy Enforcement
Policies are automatically attached based on:
- Space membership
- Environment labels
- Resource tags

## Testing

Each module includes comprehensive tests:

```bash
# Test a specific module
cd modules/networking/azure-vnet/examples/basic
terraform init
terraform plan
terraform apply -auto-approve
terraform destroy -auto-approve
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines.

## License

MIT License - see [LICENSE](LICENSE) for details.

## Support

- Documentation: [Link to docs]
- Issues: [GitHub Issues](https://github.com/your-org/spacelift-azurerm-alz/issues)
- Discussions: [GitHub Discussions](https://github.com/your-org/spacelift-azurerm-alz/discussions)
