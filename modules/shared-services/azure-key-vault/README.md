# Azure Key Vault Module

Terraform module for Azure Key Vault with RBAC authorization support.

## Features
- RBAC authorization (recommended)
- Network ACLs support
- Purge protection
- Soft delete with configurable retention

## Usage

```hcl
module "key_vault" {
  source = "../../modules/shared-services/azure-key-vault"

  name                = "kv-prod-001"
  resource_group_name = azurerm_resource_group.shared.name
  location            = "eastus"

  enable_rbac_authorization = true
  purge_protection_enabled  = true

  tags = {
    Environment = "Production"
  }
}
```

## License
MIT License - see [LICENSE](../../../LICENSE) for details.
