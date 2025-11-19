# Azure Landing Zone Modules

This directory contains reusable Terraform modules for building Azure landing zones with Spacelift.

## Module Categories

### Networking Foundation (Priority 1)
Core networking building blocks:
- **azure-vnet**: Virtual networks with DDoS protection and DNS configuration
- **azure-subnet**: Subnets with delegation and service endpoints
- **azure-nsg**: Network security groups with rule management
- **azure-route-table**: Route tables for hub-spoke traffic routing

### Hub Networking (Priority 2)
Centralized hub connectivity:
- **azure-firewall**: Azure Firewall with multiple public IPs
- **azure-vpn-gateway**: Site-to-site and point-to-site VPN
- **azure-bastion**: Secure VM access without public IPs
- **azure-vnet-peering**: Hub-spoke peering automation

### Shared Services (Priority 3)
Platform-wide shared resources:
- **azure-log-analytics**: Centralized logging workspace
- **azure-key-vault**: Secrets and certificate management
- **azure-container-registry**: Container image registry
- **azure-storage-account**: Storage for diagnostics and state

### Management (Priority 4)
Governance and management:
- **azure-management-group**: Management group hierarchy
- **azure-policy-assignment**: Azure Policy deployment
- **azure-rbac**: Role-based access control

## Usage

Each module is self-contained and can be used independently:

```hcl
module "example" {
  source = "./modules/category/module-name"

  # Required variables
  name                = "resource-name"
  resource_group_name = "rg-name"
  location            = "eastus"

  # Optional variables
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

## Spacelift Integration

All modules include `.spacelift/config.yml` for:
- Automatic module registry registration
- Automated testing on changes
- Version management

## Testing

Test modules locally:

```bash
cd modules/category/module-name/examples/basic
terraform init
terraform plan
```

## Standards

All modules follow:
- Terraform/OpenTofu >= 1.8.0
- Azure provider >= 4.0
- Consistent output patterns (minimum: `id`, `name`)
- Comprehensive examples
- Full test coverage
