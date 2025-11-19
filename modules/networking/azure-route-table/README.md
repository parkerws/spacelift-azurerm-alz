# Azure Route Table Module

Terraform module for creating Azure Route Tables with User-Defined Routes (UDR) for hub-spoke networking patterns.

## Features

- ✅ Route table creation with comprehensive routing rules
- ✅ Support for all next hop types (VirtualAppliance, VNetLocal, Internet, VirtualNetworkGateway, None)
- ✅ BGP route propagation control
- ✅ Routes as separate resources for better flexibility
- ✅ Hub-spoke routing patterns
- ✅ Forced tunneling support
- ✅ Full input validation

## Usage

### Basic Example

```hcl
module "route_table" {
  source = "../../modules/networking/azure-route-table"

  name                = "rt-workload-001"
  resource_group_name = azurerm_resource_group.network.name
  location            = "eastus"

  routes = [
    {
      name           = "default-internet"
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "Internet"
    }
  ]

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Hub-Spoke Pattern: Spoke to Hub via Azure Firewall

```hcl
module "route_table_spoke" {
  source = "../../modules/networking/azure-route-table"

  name                = "rt-spoke-001"
  resource_group_name = azurerm_resource_group.network.name
  location            = "eastus"

  # Disable BGP to prevent on-premises routes from bypassing firewall
  disable_bgp_route_propagation = true

  routes = [
    {
      name                   = "default-to-firewall"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.0.4" # Azure Firewall IP
    },
    {
      name                   = "to-other-spokes"
      address_prefix         = "10.0.0.0/8"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.0.4"
    },
    {
      name                   = "to-on-premises"
      address_prefix         = "192.168.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.0.4"
    }
  ]

  tags = {
    NetworkType = "Spoke"
  }
}
```

### Gateway Subnet Route Table (Hub)

```hcl
module "route_table_gateway" {
  source = "../../modules/networking/azure-route-table"

  name                = "rt-gateway-subnet-001"
  resource_group_name = azurerm_resource_group.hub.name
  location            = "eastus"

  # Enable BGP for VPN/ExpressRoute
  disable_bgp_route_propagation = false

  routes = [
    {
      name                   = "spoke1-via-firewall"
      address_prefix         = "10.1.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.0.4"
    },
    {
      name                   = "spoke2-via-firewall"
      address_prefix         = "10.2.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.0.4"
    }
  ]

  tags = {
    Purpose = "GatewaySubnet"
  }
}
```

### Forced Tunneling (All Traffic to On-Premises)

```hcl
module "route_table_forced_tunnel" {
  source = "../../modules/networking/azure-route-table"

  name                = "rt-forced-tunnel-001"
  resource_group_name = azurerm_resource_group.network.name
  location            = "eastus"

  disable_bgp_route_propagation = true

  routes = [
    {
      name           = "default-to-onprem"
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "VirtualNetworkGateway"
    }
  ]

  tags = {
    Pattern = "ForcedTunneling"
  }
}
```

### Block Internet Access (Private Endpoints)

```hcl
module "route_table_private_endpoints" {
  source = "../../modules/networking/azure-route-table"

  name                = "rt-private-endpoints-001"
  resource_group_name = azurerm_resource_group.network.name
  location            = "eastus"

  routes = [
    {
      name           = "block-internet"
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "None"
    }
  ]

  tags = {
    Purpose = "PrivateEndpoints"
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
| [azurerm_route_table.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | resource |
| [azurerm_route.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the route table. Changing this forces a new resource to be created. | `string` | n/a | yes |
| resource_group_name | The name of the resource group in which to create the route table. Changing this forces a new resource to be created. | `string` | n/a | yes |
| location | The location/region where the route table is created. Changing this forces a new resource to be created. | `string` | n/a | yes |
| disable_bgp_route_propagation | Boolean flag which controls propagation of routes learned by BGP on that route table. Defaults to false. | `bool` | `false` | no |
| routes | List of routes to create. Routes are created as separate resources for better flexibility. | `list(object({...}))` | `[]` | no |
| tags | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |

### Route Object Structure

Each route in `routes` supports:

| Attribute | Description | Type | Required |
|-----------|-------------|------|----------|
| name | Route name | `string` | yes |
| address_prefix | Destination CIDR | `string` | yes |
| next_hop_type | Next hop type | `string` | yes |
| next_hop_in_ip_address | Next hop IP (required for VirtualAppliance) | `string` | conditional |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the route table. |
| name | The name of the route table. |
| resource_group_name | The name of the resource group in which the route table exists. |
| location | The location/region where the route table exists. |
| route_ids | Map of route names to their IDs. |
| routes | The routes configured in the route table. |
| subnets | The collection of subnets associated with this route table. |
| disable_bgp_route_propagation | Whether BGP route propagation is disabled. |
| this | The full route table resource object. |

## Examples

See the [examples](./examples/) directory for complete, working examples:

- [Basic](./examples/basic/) - Simple routing configuration
- [Advanced](./examples/advanced/) - Hub-spoke, forced tunneling, multi-region patterns

## Next Hop Types

### VirtualAppliance
Routes traffic to a Network Virtual Appliance (NVA) like Azure Firewall, Palo Alto, or Cisco.
- **Requires**: `next_hop_in_ip_address`
- **Use case**: Hub-spoke with centralized firewall
- **Example**: `next_hop_in_ip_address = "10.0.0.4"`

### VNetLocal
Routes traffic within the local virtual network.
- **Use case**: Explicit local routing
- **Note**: Usually not needed due to system routes

### Internet
Routes traffic directly to the internet via Azure's default gateway.
- **Use case**: Allow internet access without inspection
- **Note**: Default behavior for public IPs

### VirtualNetworkGateway
Routes traffic through VPN Gateway or ExpressRoute Gateway.
- **Use case**: Forced tunneling to on-premises
- **Note**: Gateway must exist in the VNet

### None
Drops traffic matching the address prefix.
- **Use case**: Block specific destinations (e.g., internet for private endpoints)
- **Example**: Block 0.0.0.0/0 for isolated subnets

## Common Routing Patterns

### Pattern 1: Spoke → Hub Firewall

All spoke traffic (internet, other spokes, on-premises) routes through hub firewall:

```hcl
routes = [
  {
    name                   = "default-to-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.firewall_private_ip
  }
]
disable_bgp_route_propagation = true
```

### Pattern 2: Gateway Subnet

Routes from on-premises to spokes via firewall:

```hcl
routes = [
  {
    name                   = "spoke1-via-firewall"
    address_prefix         = "10.1.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.firewall_private_ip
  }
]
disable_bgp_route_propagation = false  # Allow BGP for VPN/ER
```

### Pattern 3: Forced Tunneling

Send all traffic (including internet) to on-premises:

```hcl
routes = [
  {
    name           = "force-tunnel-default"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualNetworkGateway"
  }
]
```

### Pattern 4: Isolated Subnet

Block internet, allow only VNet traffic:

```hcl
routes = [
  {
    name           = "block-internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "None"
  }
]
```

## Important Notes

### BGP Route Propagation

- **Enabled (default)**: Routes learned via VPN/ExpressRoute automatically propagate
- **Disabled**: Prevents automatic route propagation, useful for:
  - Forcing traffic through firewall
  - Preventing route conflicts
  - Explicit routing control

### Route Conflicts

Routes are evaluated in this order:
1. User-defined routes (this module)
2. BGP routes (if enabled)
3. System routes

More specific routes (longer prefix) always win.

### Azure Firewall IP

Azure Firewall uses the **first usable IP** in AzureFirewallSubnet:
- Subnet: 10.0.0.0/26
- Firewall IP: 10.0.0.4 (first 3 IPs reserved by Azure)

### Special Subnets

Some subnets have routing restrictions:
- **GatewaySubnet**: Cannot have route table attached in some scenarios
- **AzureFirewallSubnet**: Cannot have route table attached
- **AzureBastionSubnet**: Must allow internet access

### Route Limits

- Max routes per route table: 400
- Max route tables per subscription: 200 (default)

### System Routes

Azure creates default system routes for:
- VNet address space
- VNet peering
- Service endpoints
- Internet

User-defined routes override system routes.

## Troubleshooting

### Traffic Not Routing Through Firewall

Check:
1. Route table is associated with subnet
2. `next_hop_in_ip_address` is correct
3. Firewall has IP forwarding enabled
4. NSG allows traffic

### BGP Routes Not Propagating

Check:
1. `disable_bgp_route_propagation = false`
2. VPN/ExpressRoute Gateway is provisioned
3. BGP is enabled on gateway

### Forced Tunneling Not Working

Check:
1. VPN Gateway is deployed
2. Default route (0.0.0.0/0) points to VirtualNetworkGateway
3. On-premises accepts and routes Azure traffic

## Hub-Spoke Best Practices

1. **Hub Route Tables**:
   - Gateway Subnet: Route spokes through firewall
   - Firewall Subnet: No route table needed
   - Bastion Subnet: No route table needed

2. **Spoke Route Tables**:
   - Default route to firewall
   - Disable BGP propagation
   - One route table per spoke (or shared if identical routing)

3. **Naming Convention**:
   - `rt-{purpose}-{environment}-{region}-{number}`
   - Examples: `rt-spoke-prod-eastus-001`, `rt-gateway-prod-eastus-001`

## Spacelift Integration

This module includes a `.spacelift/config.yml` file for automatic:
- Module registry registration
- Automated testing on changes
- Policy attachment

## Contributing

See [CONTRIBUTING.md](../../../CONTRIBUTING.md) for development guidelines.

## License

MIT License - see [LICENSE](../../../LICENSE) for details.
