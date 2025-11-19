# Azure Virtual Network Module

Terraform module for creating Azure Virtual Networks with support for DDoS protection, custom DNS, encryption, and BGP community configuration.

## Features

- ✅ Virtual network creation with single or multiple address spaces
- ✅ DDoS Protection Plan integration
- ✅ Custom DNS server configuration
- ✅ VNet encryption support (AllowUnencrypted/DropUnencrypted)
- ✅ BGP community configuration for ExpressRoute
- ✅ Flow timeout configuration for connection tracking
- ✅ Edge Zone support
- ✅ Comprehensive tagging support
- ✅ Full validation of inputs

## Usage

### Basic Example

```hcl
module "vnet" {
  source = "../../modules/networking/azure-vnet"

  name                = "vnet-prod-eastus-001"
  resource_group_name = azurerm_resource_group.network.name
  location            = "eastus"
  address_space       = ["10.0.0.0/16"]

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Advanced Example with All Features

```hcl
module "vnet" {
  source = "../../modules/networking/azure-vnet"

  name                = "vnet-hub-prod-eastus-001"
  resource_group_name = azurerm_resource_group.network.name
  location            = "eastus"
  address_space       = ["10.0.0.0/16", "10.1.0.0/16"]

  # Custom DNS servers (Azure Firewall or on-premises DNS)
  dns_servers = ["10.0.0.4", "10.0.0.5"]

  # DDoS Protection
  ddos_protection_plan = {
    id     = azurerm_network_ddos_protection_plan.main.id
    enable = true
  }

  # VNet encryption
  encryption = {
    enforcement = "AllowUnencrypted"
  }

  # Connection tracking timeout
  flow_timeout_in_minutes = 10

  # BGP community for ExpressRoute
  bgp_community = "12076:20001"

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    CostCenter  = "IT-Network"
  }
}
```

### Hub-and-Spoke Pattern

```hcl
# Hub VNet
module "hub_vnet" {
  source = "../../modules/networking/azure-vnet"

  name                = "vnet-hub-prod-eastus-001"
  resource_group_name = azurerm_resource_group.hub.name
  location            = "eastus"
  address_space       = ["10.0.0.0/16"]

  dns_servers = ["10.0.0.4"] # Azure Firewall or DNS server

  ddos_protection_plan = {
    id     = azurerm_network_ddos_protection_plan.hub.id
    enable = true
  }

  tags = local.hub_tags
}

# Spoke VNet
module "spoke_vnet" {
  source = "../../modules/networking/azure-vnet"

  name                = "vnet-spoke-app1-prod-eastus-001"
  resource_group_name = azurerm_resource_group.spoke.name
  location            = "eastus"
  address_space       = ["10.1.0.0/16"]

  # Use hub DNS servers
  dns_servers = ["10.0.0.4"]

  tags = local.spoke_tags
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
| [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the virtual network. Changing this forces a new resource to be created. | `string` | n/a | yes |
| resource_group_name | The name of the resource group in which to create the virtual network. Changing this forces a new resource to be created. | `string` | n/a | yes |
| location | The location/region where the virtual network is created. Changing this forces a new resource to be created. | `string` | n/a | yes |
| address_space | The address space that is used by the virtual network. You can supply more than one address space. | `list(string)` | n/a | yes |
| bgp_community | The BGP community attribute in format <as-number>:<community-value>. The as-number segment is the Microsoft ASN, which is always 12076 for now. | `string` | `null` | no |
| ddos_protection_plan | A DDoS protection plan configuration block. If enabled, a DDoS protection plan must be specified. | `object({ id = string, enable = bool })` | `null` | no |
| dns_servers | List of IP addresses of DNS servers. If no values are provided, the default Azure DNS will be used. | `list(string)` | `[]` | no |
| edge_zone | Specifies the Edge Zone within the Azure Region where this Virtual Network should exist. Changing this forces a new Virtual Network to be created. | `string` | `null` | no |
| encryption | An encryption block to enable VNet encryption. Enforcement must be 'AllowUnencrypted' or 'DropUnencrypted'. | `object({ enforcement = string })` | `null` | no |
| flow_timeout_in_minutes | The flow timeout in minutes for the Virtual Network, which is used to enable connection tracking for intra-VM flows. Possible values are between 4 and 30 minutes. | `number` | `null` | no |
| tags | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the virtual network. |
| name | The name of the virtual network. |
| resource_group_name | The name of the resource group in which the virtual network was created. |
| location | The location/region where the virtual network exists. |
| address_space | The address space of the virtual network. |
| guid | The GUID of the virtual network. |
| subnet_ids | The IDs of subnets created within this virtual network. Note: Subnets managed separately won't appear here. |
| dns_servers | The list of DNS servers configured for the virtual network. |
| bgp_community | The BGP community attribute of the virtual network. |
| this | The full virtual network resource object. Use this output for accessing attributes not explicitly exposed. |

## Examples

See the [examples](./examples/) directory for complete, working examples:

- [Basic](./examples/basic/) - Minimal VNet configuration
- [Advanced](./examples/advanced/) - Full-featured VNet with DDoS, DNS, and encryption

## Testing

Run the included tests:

```bash
# Validate basic example
cd examples/basic
terraform init
terraform validate
terraform plan

# Validate advanced example
cd examples/advanced
terraform init
terraform validate
terraform plan
```

## Important Notes

### DNS Servers

- Terraform currently provides both a standalone `azurerm_virtual_network_dns_servers` resource and allows DNS servers to be defined inline within the VNet resource
- You cannot use a VNet with inline DNS servers in conjunction with the standalone DNS servers resource
- This module uses inline DNS configuration

### DDoS Protection

- DDoS Protection Plans are billed per plan (not per VNet)
- A single DDoS Protection Plan can protect multiple VNets
- Consider the cost implications before enabling DDoS protection

### VNet Encryption

- VNet encryption requires specific VM SKUs that support encryption
- Not all Azure regions support VNet encryption
- Enforcement options:
  - `AllowUnencrypted`: Allows both encrypted and unencrypted traffic (default)
  - `DropUnencrypted`: Drops all unencrypted traffic

### BGP Community

- Only applicable when using ExpressRoute
- Format: `12076:<community-value>` (12076 is the Microsoft ASN)
- Used for route filtering and traffic engineering

## Common Patterns

### Hub VNet for Landing Zones

```hcl
module "hub_vnet" {
  source = "../../modules/networking/azure-vnet"

  name                = "vnet-hub-${var.environment}-${var.location}-001"
  resource_group_name = azurerm_resource_group.connectivity.name
  location            = var.location
  address_space       = var.hub_address_space

  dns_servers = [
    cidrhost(var.hub_address_space[0], 4) # Azure Firewall IP
  ]

  ddos_protection_plan = {
    id     = var.ddos_protection_plan_id
    enable = true
  }

  flow_timeout_in_minutes = 10

  tags = merge(var.common_tags, {
    NetworkType = "Hub"
    Purpose     = "Connectivity"
  })
}
```

### Spoke VNet with Custom DNS

```hcl
module "spoke_vnet" {
  source = "../../modules/networking/azure-vnet"

  name                = "vnet-spoke-${var.workload_name}-${var.environment}-${var.location}-001"
  resource_group_name = azurerm_resource_group.workload.name
  location            = var.location
  address_space       = var.spoke_address_space

  # Inherit DNS from hub
  dns_servers = var.hub_dns_servers

  tags = merge(var.common_tags, {
    NetworkType = "Spoke"
    Workload    = var.workload_name
  })
}
```

## Spacelift Integration

This module includes a `.spacelift/config.yml` file for automatic:
- Module registry registration
- Automated testing on changes
- Policy attachment

## Contributing

See [CONTRIBUTING.md](../../../CONTRIBUTING.md) for development guidelines.

## License

MIT License - see [LICENSE](../../../LICENSE) for details.
