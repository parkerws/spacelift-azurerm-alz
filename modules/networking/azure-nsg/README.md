# Azure Network Security Group Module

Terraform module for creating Azure Network Security Groups with comprehensive security rule management and Application Security Group support.

## Features

- ✅ Network Security Group creation
- ✅ Security rules as separate resources (recommended approach)
- ✅ Support for single and multiple port ranges
- ✅ Support for single and multiple address prefixes
- ✅ Application Security Group integration
- ✅ Service tags support (Internet, VirtualNetwork, AzureLoadBalancer, etc.)
- ✅ Full validation of rule parameters
- ✅ Comprehensive examples for common patterns

## Usage

### Basic Example

```hcl
module "nsg" {
  source = "../../modules/networking/azure-nsg"

  name                = "nsg-workload-001"
  resource_group_name = azurerm_resource_group.network.name
  location            = "eastus"

  security_rules = [
    {
      name                       = "AllowHTTPS"
      description                = "Allow HTTPS inbound"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "DenyAll"
      description                = "Deny all other traffic"
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### With Application Security Groups

```hcl
resource "azurerm_application_security_group" "web" {
  name                = "asg-web"
  resource_group_name = azurerm_resource_group.network.name
  location            = "eastus"
}

resource "azurerm_application_security_group" "app" {
  name                = "asg-app"
  resource_group_name = azurerm_resource_group.network.name
  location            = "eastus"
}

module "nsg" {
  source = "../../modules/networking/azure-nsg"

  name                = "nsg-web-tier-001"
  resource_group_name = azurerm_resource_group.network.name
  location            = "eastus"

  security_rules = [
    {
      name                                       = "AllowHTTPSFromInternet"
      description                                = "Allow HTTPS from internet to web tier"
      priority                                   = 100
      direction                                  = "Inbound"
      access                                     = "Allow"
      protocol                                   = "Tcp"
      source_port_range                          = "*"
      destination_port_range                     = "443"
      source_address_prefix                      = "Internet"
      destination_application_security_group_ids = [azurerm_application_security_group.web.id]
    },
    {
      name                                  = "AllowWebToApp"
      description                           = "Allow web tier to app tier"
      priority                              = 200
      direction                             = "Outbound"
      access                                = "Allow"
      protocol                              = "Tcp"
      source_port_range                     = "*"
      destination_port_range                = "8080"
      source_application_security_group_ids = [azurerm_application_security_group.web.id]
      destination_application_security_group_ids = [azurerm_application_security_group.app.id]
    }
  ]

  tags = {
    Tier = "Web"
  }
}
```

### With Multiple Ports and Address Ranges

```hcl
module "nsg" {
  source = "../../modules/networking/azure-nsg"

  name                = "nsg-microservices-001"
  resource_group_name = azurerm_resource_group.network.name
  location            = "eastus"

  security_rules = [
    {
      name                       = "AllowMicroservicePorts"
      description                = "Allow multiple service ports"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_ranges    = ["8080", "8081", "8082", "9090"]
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
    },
    {
      name                       = "AllowFromMultipleSubnets"
      description                = "Allow from specific subnets"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      source_address_prefixes    = ["10.0.1.0/24", "10.0.2.0/24"]
      destination_port_range     = "443"
      destination_address_prefix = "*"
    }
  ]

  tags = {
    Pattern = "Microservices"
  }
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
| [azurerm_network_security_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the network security group. Changing this forces a new resource to be created. | `string` | n/a | yes |
| resource_group_name | The name of the resource group in which to create the network security group. Changing this forces a new resource to be created. | `string` | n/a | yes |
| location | The location/region where the network security group is created. Changing this forces a new resource to be created. | `string` | n/a | yes |
| security_rules | List of security rules to create. | `list(object({...}))` | `[]` | no |
| tags | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |

### Security Rule Object Structure

Each security rule in `security_rules` supports:

| Attribute | Description | Type | Required |
|-----------|-------------|------|----------|
| name | Rule name | `string` | yes |
| description | Rule description | `string` | no |
| priority | Priority (100-4096) | `number` | yes |
| direction | Inbound or Outbound | `string` | yes |
| access | Allow or Deny | `string` | yes |
| protocol | Tcp, Udp, Icmp, Esp, Ah, or * | `string` | yes |
| source_port_range | Single source port or range | `string` | no |
| source_port_ranges | Multiple source ports or ranges | `list(string)` | no |
| destination_port_range | Single destination port or range | `string` | no |
| destination_port_ranges | Multiple destination ports or ranges | `list(string)` | no |
| source_address_prefix | Single source address or CIDR | `string` | no |
| source_address_prefixes | Multiple source addresses or CIDRs | `list(string)` | no |
| destination_address_prefix | Single destination address or CIDR | `string` | no |
| destination_address_prefixes | Multiple destination addresses or CIDRs | `list(string)` | no |
| source_application_security_group_ids | Source ASG IDs | `list(string)` | no |
| destination_application_security_group_ids | Destination ASG IDs | `list(string)` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the network security group. |
| name | The name of the network security group. |
| resource_group_name | The name of the resource group in which the network security group exists. |
| location | The location/region where the network security group exists. |
| security_rule_ids | Map of security rule names to their IDs. |
| security_rules | The security rules configured on the network security group. |
| this | The full network security group resource object. |

## Examples

See the [examples](./examples/) directory for complete, working examples:

- [Basic](./examples/basic/) - Common security rules
- [Advanced](./examples/advanced/) - Three-tier architecture with ASGs

## Common Service Tags

Use these service tags instead of IP addresses:

- `Internet` - Internet traffic
- `VirtualNetwork` - Virtual network address space
- `AzureLoadBalancer` - Azure Load Balancer
- `AzureCloud` - All Azure datacenter IPs
- `AzureKeyVault` - Azure Key Vault
- `AzureActiveDirectory` - Azure AD
- `Storage` - Azure Storage
- `Sql` - Azure SQL Database
- `AppService` - Azure App Service

Region-specific tags: `Storage.EastUS`, `Sql.WestEurope`, etc.

## Security Best Practices

### Rule Priority Planning

- **100-199**: Critical allow rules (management access)
- **200-999**: Application-specific allow rules
- **1000-1999**: Conditional allow rules
- **2000-3999**: Service-specific rules
- **4000-4095**: Explicit deny rules
- **4096**: Catch-all deny rule

### Least Privilege

1. Start with deny-all rule (priority 4096)
2. Add specific allow rules as needed
3. Use smallest possible CIDR ranges
4. Limit port ranges to minimum required

### Application Security Groups

ASGs provide:
- Micro-segmentation within VNets
- Rules based on application tiers
- Independence from IP addresses
- Easier rule management at scale

### Avoid Common Mistakes

1. **Don't use wildcard rules** - Specify exact ports and sources
2. **Don't allow Internet → *:*** - Always restrict inbound from Internet
3. **Don't use priority gaps < 10** - Leave room for future rules
4. **Don't mix inline and standalone rules** - Use one pattern consistently

## Important Notes

### Rule Evaluation

- Rules are processed by priority (lowest number first)
- Processing stops at first match
- Default rules (65000+) evaluated last
- Explicit deny rules override implicit allows

### Default Security Rules

Azure creates default rules (cannot be deleted):
- AllowVNetInBound (priority 65000)
- AllowAzureLoadBalancerInBound (priority 65001)
- DenyAllInBound (priority 65500)
- AllowVNetOutBound (priority 65000)
- AllowInternetOutBound (priority 65001)
- DenyAllOutBound (priority 65500)

### Rule Limits

- Max rules per NSG: 1,000
- Max NSGs per subscription: 5,000 (default)
- Rule priority range: 100-4096

### Module Design Choice

This module uses **separate security rule resources** instead of inline rules. Benefits:
- Easier to manage individual rules
- Avoid conflicts with external rule management
- Better for dynamic rule creation
- Follows Terraform best practices

## Spacelift Integration

This module includes a `.spacelift/config.yml` file for automatic:
- Module registry registration
- Automated testing on changes
- Security policy attachment

## Contributing

See [CONTRIBUTING.md](../../../CONTRIBUTING.md) for development guidelines.

## License

MIT License - see [LICENSE](../../../LICENSE) for details.
