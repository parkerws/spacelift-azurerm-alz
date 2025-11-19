# Azure Subnet Module

Terraform module for creating Azure Subnets with support for service endpoints, delegations, and network policies.

## Features

- ✅ Subnet creation with single or multiple address prefixes
- ✅ Service endpoint configuration for Azure services
- ✅ Subnet delegation for Azure services (AKS, App Service, NetApp, etc.)
- ✅ Private endpoint network policies (NSG and route table support)
- ✅ Private link service network policies
- ✅ Default outbound access control
- ✅ Service endpoint policy association
- ✅ Full input validation

## Usage

### Basic Example

```hcl
module "subnet" {
  source = "../../modules/networking/azure-subnet"

  name                 = "snet-workload-001"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}
```

### With Service Endpoints

```hcl
module "subnet" {
  source = "../../modules/networking/azure-subnet"

  name                 = "snet-data-001"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]

  service_endpoints = [
    "Microsoft.Storage",
    "Microsoft.Sql",
    "Microsoft.KeyVault"
  ]
}
```

### AKS Subnet with Delegation

```hcl
module "subnet_aks" {
  source = "../../modules/networking/azure-subnet"

  name                 = "snet-aks-001"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.10.0/24"]

  # Disable default outbound for enhanced security
  default_outbound_access_enabled = false

  service_endpoints = [
    "Microsoft.ContainerRegistry",
    "Microsoft.Storage"
  ]

  delegations = [
    {
      name = "aks-delegation"
      service_delegation = {
        name = "Microsoft.ContainerService/managedClusters"
        actions = [
          "Microsoft.Network/virtualNetworks/subnets/join/action"
        ]
      }
    }
  ]

  private_endpoint_network_policies = "NetworkSecurityGroupEnabled"
}
```

### App Service Subnet

```hcl
module "subnet_app" {
  source = "../../modules/networking/azure-subnet"

  name                 = "snet-app-001"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.20.0/24"]

  delegations = [
    {
      name = "app-service-delegation"
      service_delegation = {
        name = "Microsoft.Web/serverFarms"
        actions = [
          "Microsoft.Network/virtualNetworks/subnets/action"
        ]
      }
    }
  ]
}
```

### Private Endpoint Subnet

```hcl
module "subnet_pe" {
  source = "../../modules/networking/azure-subnet"

  name                 = "snet-private-endpoints-001"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.30.0/24"]

  # Enable network policies for private endpoints (supports NSG and route tables)
  private_endpoint_network_policies = "Enabled"

  service_endpoints = [
    "Microsoft.Storage",
    "Microsoft.KeyVault"
  ]
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.8.0 |
| azurerm | >= 4.0.0, < 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 4.0.0, < 5.0.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the subnet. Changing this forces a new resource to be created. | `string` | n/a | yes |
| resource_group_name | The name of the resource group in which to create the subnet. Changing this forces a new resource to be created. | `string` | n/a | yes |
| virtual_network_name | The name of the virtual network to which to attach the subnet. Changing this forces a new resource to be created. | `string` | n/a | yes |
| address_prefixes | The address prefixes to use for the subnet. Each subnet must have a unique address prefix within the virtual network. | `list(string)` | n/a | yes |
| default_outbound_access_enabled | Enable default outbound access to the internet for the subnet. Defaults to true. Set to false to disable default outbound internet access. | `bool` | `true` | no |
| delegations | One or more delegation blocks for subnet delegation to Azure services. Each delegation requires a unique name and service delegation details. | `list(object({ name = string, service_delegation = object({ name = string, actions = optional(list(string)) }) }))` | `[]` | no |
| private_endpoint_network_policies | Enable or disable network policies for private endpoints on the subnet. Possible values are Disabled, Enabled, NetworkSecurityGroupEnabled, and RouteTableEnabled. Defaults to Disabled. | `string` | `"Disabled"` | no |
| private_link_service_network_policies_enabled | Enable or disable network policies for the private link service on the subnet. Defaults to true. | `bool` | `true` | no |
| service_endpoints | The list of Service endpoints to associate with the subnet. | `list(string)` | `[]` | no |
| service_endpoint_policy_ids | The list of IDs of Service Endpoint Policies to associate with the subnet. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the subnet. |
| name | The name of the subnet. |
| resource_group_name | The name of the resource group in which the subnet exists. |
| virtual_network_name | The name of the virtual network to which the subnet is attached. |
| address_prefixes | The address prefixes for the subnet. |
| service_endpoints | The list of service endpoints associated with the subnet. |
| delegations | The list of delegations configured on the subnet. |
| private_endpoint_network_policies | The network policies setting for private endpoints on the subnet. |
| this | The full subnet resource object. Use this output for accessing attributes not explicitly exposed. |

## Examples

See the [examples](./examples/) directory for complete, working examples:

- [Basic](./examples/basic/) - Minimal subnet configuration
- [Advanced](./examples/advanced/) - Multiple subnets with delegations and service endpoints

## Common Service Delegations

| Service | Delegation Name | Actions |
|---------|----------------|---------|
| AKS | `Microsoft.ContainerService/managedClusters` | `Microsoft.Network/virtualNetworks/subnets/join/action` |
| App Service | `Microsoft.Web/serverFarms` | `Microsoft.Network/virtualNetworks/subnets/action` |
| Azure SQL MI | `Microsoft.Sql/managedInstances` | `Microsoft.Network/virtualNetworks/subnets/join/action`, `Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action`, `Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action` |
| Azure NetApp | `Microsoft.NetApp/volumes` | `Microsoft.Network/networkinterfaces/*`, `Microsoft.Network/virtualNetworks/subnets/join/action` |
| Azure Batch | `Microsoft.Batch/batchAccounts` | `Microsoft.Network/virtualNetworks/subnets/action` |
| Container Instances | `Microsoft.ContainerInstance/containerGroups` | `Microsoft.Network/virtualNetworks/subnets/action` |

## Common Service Endpoints

- `Microsoft.Storage` - Azure Storage
- `Microsoft.Sql` - Azure SQL Database
- `Microsoft.KeyVault` - Azure Key Vault
- `Microsoft.ContainerRegistry` - Azure Container Registry
- `Microsoft.ServiceBus` - Azure Service Bus
- `Microsoft.EventHub` - Azure Event Hubs
- `Microsoft.AzureCosmosDB` - Azure Cosmos DB
- `Microsoft.Web` - Azure App Service
- `Microsoft.AzureActiveDirectory` - Azure Active Directory
- `Microsoft.Storage.Global` - Azure Storage (global)

## Important Notes

### Private Endpoint Network Policies

Starting with newer API versions, you can enable network policies (NSG and route tables) on subnets with private endpoints:

- `Disabled` - No network policies (legacy behavior)
- `Enabled` - Enable both NSG and route table policies
- `NetworkSecurityGroupEnabled` - Enable only NSG policies
- `RouteTableEnabled` - Enable only route table policies

### Default Outbound Access

Setting `default_outbound_access_enabled = false` requires explicit outbound connectivity through:
- NAT Gateway
- Load Balancer with outbound rules
- Instance-level public IP
- Azure Firewall

### Subnet Delegation

- Delegated subnets can only be used for the delegated service
- Some services require specific address space sizes
- Delegation cannot be removed if resources exist in the subnet

### Special Subnets

Azure reserves certain subnet names:
- `GatewaySubnet` - For VPN/ExpressRoute gateways (no NSG allowed)
- `AzureFirewallSubnet` - For Azure Firewall (minimum /26)
- `AzureBastionSubnet` - For Azure Bastion (minimum /26)

## Spacelift Integration

This module includes a `.spacelift/config.yml` file for automatic:
- Module registry registration
- Automated testing on changes
- Policy attachment

## Contributing

See [CONTRIBUTING.md](../../../CONTRIBUTING.md) for development guidelines.

## License

MIT License - see [LICENSE](../../../LICENSE) for details.
