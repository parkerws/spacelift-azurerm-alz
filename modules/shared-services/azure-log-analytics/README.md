# Azure Log Analytics Workspace Module

Terraform module for creating Azure Log Analytics Workspace for centralized logging and monitoring.

## Features

- ✅ Multiple SKU options (PerGB2018, CapacityReservation, etc.)
- ✅ Configurable data retention (7-730 days)
- ✅ Daily quota management
- ✅ Managed identity support
- ✅ Internet ingestion/query control
- ✅ Solutions integration (Container Insights, Security, VM Insights)
- ✅ CMK encryption support

## Usage

### Basic Workspace

```hcl
module "log_analytics" {
  source = "../../modules/shared-services/azure-log-analytics"

  name                = "law-prod-001"
  resource_group_name = azurerm_resource_group.monitoring.name
  location            = "eastus"

  sku               = "PerGB2018"
  retention_in_days = 30

  tags = {
    Environment = "Production"
  }
}
```

### With Solutions

```hcl
module "log_analytics" {
  source = "../../modules/shared-services/azure-log-analytics"

  name                = "law-prod-001"
  resource_group_name = azurerm_resource_group.monitoring.name
  location            = "eastus"

  sku               = "PerGB2018"
  retention_in_days = 90
  daily_quota_gb    = 10

  identity_type = "SystemAssigned"

  solutions = {
    "ContainerInsights" = {
      publisher = "Microsoft"
      product   = "OMSGallery/ContainerInsights"
    }
    "VMInsights" = {
      publisher = "Microsoft"
      product   = "OMSGallery/VMInsights"
    }
    "SecurityInsights" = {
      publisher = "Microsoft"
      product   = "OMSGallery/SecurityInsights"
    }
  }

  tags = {
    Environment = "Production"
  }
}
```

## Outputs

| Name | Description |
|------|-------------|
| id | Workspace ID |
| workspace_id | Workspace (Customer) ID |
| primary_shared_key | Primary shared key (sensitive) |
| solution_ids | Map of solution IDs |

## Common Solutions

- `ContainerInsights` - AKS/Container monitoring
- `SecurityInsights` - Microsoft Sentinel
- `VMInsights` - VM monitoring
- `Updates` - Update management
- `ChangeTracking` - Change tracking
- `ServiceMap` - Application dependency mapping

## License

MIT License - see [LICENSE](../../../LICENSE) for details.
