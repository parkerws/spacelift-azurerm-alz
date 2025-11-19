# Azure Container Registry Module

Terraform module for Azure Container Registry with support for geo-replication, webhooks, and network restrictions.

## Features

- Basic, Standard, and Premium SKU support
- Geo-replication (Premium only)
- Network ACLs and private endpoints (Premium only)
- Webhooks for CI/CD integration
- Customer-managed encryption (Premium only)
- Content trust and retention policies (Premium only)
- Managed identity support
- Map-based webhook configuration

## Usage

### Basic Configuration

```hcl
module "acr" {
  source = "../../modules/shared-services/azure-container-registry"

  name                = "acrprod001"
  resource_group_name = azurerm_resource_group.shared.name
  location            = "eastus"
  sku                 = "Standard"

  tags = {
    Environment = "Production"
  }
}
```

### Premium with Geo-Replication

```hcl
module "acr_premium" {
  source = "../../modules/shared-services/azure-container-registry"

  name                = "acrprod001"
  resource_group_name = azurerm_resource_group.shared.name
  location            = "eastus"
  sku                 = "Premium"

  zone_redundancy_enabled = true
  data_endpoint_enabled   = true

  georeplications = [
    {
      location                  = "westus2"
      zone_redundancy_enabled   = true
      regional_endpoint_enabled = true
      tags = {
        Region = "WestUS2"
      }
    },
    {
      location                  = "northeurope"
      zone_redundancy_enabled   = true
      regional_endpoint_enabled = true
      tags = {
        Region = "NorthEurope"
      }
    }
  ]

  retention_policy = {
    enabled = true
    days    = 30
  }

  webhooks = {
    "webhook-ci" = {
      service_uri = "https://ci.example.com/webhook"
      actions     = ["push", "delete"]
      status      = "enabled"
      scope       = "myapp:*"
    }
    "webhook-prod" = {
      service_uri = "https://prod.example.com/webhook"
      actions     = ["push"]
      scope       = "prod/*"
    }
  }

  tags = {
    Environment = "Production"
  }
}
```

## License

MIT License - see [LICENSE](../../../LICENSE) for details.
