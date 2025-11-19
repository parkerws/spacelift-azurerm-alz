# Azure RBAC Module

Terraform module for Azure Role-Based Access Control (RBAC) role assignments.

## Features

- Role assignments at any scope (management group, subscription, resource group, resource)
- Built-in and custom role definitions
- Support for all principal types (User, Group, ServicePrincipal, ForeignGroup, Device)
- Conditional access with ABAC (Attribute-Based Access Control)
- Delegated managed identity support
- Service principal replication handling

## Usage

### Basic Configuration - Subscription Scope

```hcl
data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

module "rbac_contributor" {
  source = "../../modules/management/azure-rbac"

  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
  principal_type       = "ServicePrincipal"
  description          = "Contributor access for deployment service principal"
}
```

### Resource Group Scope

```hcl
resource "azurerm_resource_group" "example" {
  name     = "rg-example"
  location = "eastus"
}

module "rbac_reader" {
  source = "../../modules/management/azure-rbac"

  scope                = azurerm_resource_group.example.id
  role_definition_name = "Reader"
  principal_id         = "00000000-0000-0000-0000-000000000000" # User or group object ID
  principal_type       = "Group"
  description          = "Read-only access for operations team"
}
```

### Management Group Scope

```hcl
data "azurerm_management_group" "platform" {
  name = "mg-platform"
}

module "rbac_mg_owner" {
  source = "../../modules/management/azure-rbac"

  scope                = data.azurerm_management_group.platform.id
  role_definition_name = "Owner"
  principal_id         = "00000000-0000-0000-0000-000000000000"
  principal_type       = "User"
  description          = "Platform management group owner"
}
```

### With Conditions (ABAC)

```hcl
# Conditional role assignment - only allows access to resources with specific tags
module "rbac_conditional" {
  source = "../../modules/management/azure-rbac"

  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = "00000000-0000-0000-0000-000000000000"
  principal_type       = "User"

  condition = <<-EOT
    (
      (
        !(ActionMatches{'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read'})
      )
      OR
      (
        @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:name] StringEquals 'public'
      )
    )
  EOT

  condition_version = "2.0"
  description      = "Conditional access to only read from public container"
}
```

### Custom Role Definition

```hcl
data "azurerm_subscription" "current" {}

# Custom role definition (created separately)
resource "azurerm_role_definition" "custom" {
  name  = "Custom VM Operator"
  scope = data.azurerm_subscription.current.id

  permissions {
    actions = [
      "Microsoft.Compute/virtualMachines/start/action",
      "Microsoft.Compute/virtualMachines/restart/action",
      "Microsoft.Compute/virtualMachines/read"
    ]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.current.id
  ]
}

module "rbac_custom_role" {
  source = "../../modules/management/azure-rbac"

  scope              = data.azurerm_subscription.current.id
  role_definition_id = azurerm_role_definition.custom.role_definition_resource_id
  principal_id       = "00000000-0000-0000-0000-000000000000"
  principal_type     = "User"
  description        = "Custom VM operator role assignment"
}
```

### Service Principal with Replication Check

```hcl
# For service principals that may not be fully replicated yet
module "rbac_sp" {
  source = "../../modules/management/azure-rbac"

  scope                            = data.azurerm_subscription.current.id
  role_definition_name             = "Contributor"
  principal_id                     = azurerm_user_assigned_identity.example.principal_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
  description                      = "Managed identity contributor access"
}
```

## Common Built-in Roles

- **Owner**: Full access including role assignments
- **Contributor**: Full access except role assignments
- **Reader**: Read-only access
- **User Access Administrator**: Manage user access
- **Key Vault Administrator**: Full access to Key Vault
- **Storage Blob Data Contributor**: Read, write, delete blob containers and blobs
- **Network Contributor**: Manage networks
- **Security Admin**: View and update security policies

## License

MIT License - see [LICENSE](../../../LICENSE) for details.
