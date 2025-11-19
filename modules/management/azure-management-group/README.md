# Azure Management Group Module

Terraform module for Azure Management Groups to organize subscriptions in a hierarchy.

## Features

- Management group hierarchy creation
- Parent-child relationships
- Subscription associations
- Support for Azure Landing Zone topologies
- Display name customization

## Usage

### Basic Configuration

```hcl
module "mg_platform" {
  source = "../../modules/management/azure-management-group"

  name         = "mg-platform"
  display_name = "Platform"
}
```

### Hierarchical Structure

```hcl
# Root level management group
module "mg_root" {
  source = "../../modules/management/azure-management-group"

  name         = "mg-contoso"
  display_name = "Contoso"
}

# Platform management group
module "mg_platform" {
  source = "../../modules/management/azure-management-group"

  name                       = "mg-platform"
  display_name               = "Platform"
  parent_management_group_id = module.mg_root.id
}

# Connectivity management group
module "mg_connectivity" {
  source = "../../modules/management/azure-management-group"

  name                       = "mg-connectivity"
  display_name               = "Connectivity"
  parent_management_group_id = module.mg_platform.id

  subscription_ids = [
    "00000000-0000-0000-0000-000000000001"
  ]
}

# Identity management group
module "mg_identity" {
  source = "../../modules/management/azure-management-group"

  name                       = "mg-identity"
  display_name               = "Identity"
  parent_management_group_id = module.mg_platform.id

  subscription_ids = [
    "00000000-0000-0000-0000-000000000002"
  ]
}

# Management management group
module "mg_management" {
  source = "../../modules/management/azure-management-group"

  name                       = "mg-management"
  display_name               = "Management"
  parent_management_group_id = module.mg_platform.id

  subscription_ids = [
    "00000000-0000-0000-0000-000000000003"
  ]
}

# Landing zones
module "mg_landing_zones" {
  source = "../../modules/management/azure-management-group"

  name                       = "mg-landing-zones"
  display_name               = "Landing Zones"
  parent_management_group_id = module.mg_root.id
}

module "mg_corp" {
  source = "../../modules/management/azure-management-group"

  name                       = "mg-corp"
  display_name               = "Corp"
  parent_management_group_id = module.mg_landing_zones.id
}

module "mg_online" {
  source = "../../modules/management/azure-management-group"

  name                       = "mg-online"
  display_name               = "Online"
  parent_management_group_id = module.mg_landing_zones.id
}
```

## Azure Landing Zone Structure

This module supports the standard Azure Landing Zone management group hierarchy:

```
Tenant Root
└── Enterprise Scale (mg-contoso)
    ├── Platform
    │   ├── Connectivity
    │   ├── Identity
    │   └── Management
    ├── Landing Zones
    │   ├── Corp
    │   └── Online
    ├── Sandboxes
    └── Decommissioned
```

## License

MIT License - see [LICENSE](../../../LICENSE) for details.
