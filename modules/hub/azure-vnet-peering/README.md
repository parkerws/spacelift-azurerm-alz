# Azure VNet Peering Module

Terraform module for creating Azure VNet Peering for hub-spoke network topologies.

## Features

- ✅ Bidirectional VNet peering
- ✅ Hub-spoke topology automation
- ✅ Gateway transit support (VPN/ExpressRoute)
- ✅ Forwarded traffic control
- ✅ Cross-subscription peering support
- ✅ Global VNet peering (cross-region)
- ✅ Trigger-based recreation

## Usage

### Basic Peering

```hcl
# VNet 1 to VNet 2
module "peering_1_to_2" {
  source = "../../modules/hub/azure-vnet-peering"

  name                         = "peer-vnet1-to-vnet2"
  resource_group_name          = azurerm_resource_group.network.name
  virtual_network_name         = azurerm_virtual_network.vnet1.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet2.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
}

# VNet 2 to VNet 1 (reverse peering required)
module "peering_2_to_1" {
  source = "../../modules/hub/azure-vnet-peering"

  name                         = "peer-vnet2-to-vnet1"
  resource_group_name          = azurerm_resource_group.network.name
  virtual_network_name         = azurerm_virtual_network.vnet2.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet1.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
}
```

### Hub-Spoke with Gateway Transit

```hcl
# Hub to Spoke (Hub side)
module "peering_hub_to_spoke" {
  source = "../../modules/hub/azure-vnet-peering"

  name                         = "peer-hub-to-spoke"
  resource_group_name          = azurerm_resource_group.hub.name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true  # Hub allows traffic from spoke
  allow_gateway_transit        = true  # Hub offers VPN gateway to spoke
  use_remote_gateways          = false
}

# Spoke to Hub (Spoke side)
module "peering_spoke_to_hub" {
  source = "../../modules/hub/azure-vnet-peering"

  name                         = "peer-spoke-to-hub"
  resource_group_name          = azurerm_resource_group.spoke.name
  virtual_network_name         = azurerm_virtual_network.spoke.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true  # Spoke allows traffic from other spokes via hub
  allow_gateway_transit        = false
  use_remote_gateways          = true  # Spoke uses hub's VPN gateway
}
```

### With Triggers (Auto-recreate on Changes)

```hcl
module "peering" {
  source = "../../modules/hub/azure-vnet-peering"

  name                         = "peer-hub-to-spoke"
  resource_group_name          = azurerm_resource_group.hub.name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  # Recreate peering if spoke address space changes
  triggers = {
    spoke_address_space = join(",", azurerm_virtual_network.spoke.address_space)
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.8.0 |
| azurerm | >= 4.0.0, < 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Peering name | `string` | n/a | yes |
| resource_group_name | Resource group name | `string` | n/a | yes |
| virtual_network_name | Local VNet name | `string` | n/a | yes |
| remote_virtual_network_id | Remote VNet ID | `string` | n/a | yes |
| allow_virtual_network_access | Allow VM-to-VM access | `bool` | `true` | no |
| allow_forwarded_traffic | Allow forwarded traffic | `bool` | `false` | no |
| allow_gateway_transit | Offer gateway to remote | `bool` | `false` | no |
| use_remote_gateways | Use remote's gateway | `bool` | `false` | no |
| triggers | Trigger map for recreation | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | Peering ID |
| name | Peering name |
| allow_forwarded_traffic | Whether forwarded traffic is allowed |
| allow_gateway_transit | Whether gateway transit is allowed |
| use_remote_gateways | Whether remote gateways are used |
| this | Full resource object |

## Important Notes

### Bidirectional Requirement

VNet peering is **not transitive** and requires two separate peering resources:
- VNet A → VNet B (one peering)
- VNet B → VNet A (separate peering)

Both must be configured for communication to work.

### Gateway Transit

**Hub Configuration** (offers gateway):
```hcl
allow_gateway_transit = true
use_remote_gateways   = false
```

**Spoke Configuration** (uses hub gateway):
```hcl
allow_gateway_transit = false
use_remote_gateways   = true  # Only if hub has VPN/ER gateway
```

**Important**: `use_remote_gateways` can only be `true` if remote VNet has a provisioned gateway.

### Forwarded Traffic

**When to enable `allow_forwarded_traffic`**:
- Hub-spoke topologies (both hub and spoke)
- When using Network Virtual Appliances (NVA)
- When routing traffic through Azure Firewall
- For spoke-to-spoke communication via hub

**When to disable**:
- Simple peering between two VNets
- No traffic routing required

### Non-Transitivity

VNet peering is **not transitive**:
- If A peers with B and B peers with C
- A cannot communicate with C automatically
- Use hub-spoke or custom routes for transitivity

## Hub-Spoke Patterns

### Single Hub, Multiple Spokes

```hcl
locals {
  spokes = {
    spoke1 = azurerm_virtual_network.spoke1.id
    spoke2 = azurerm_virtual_network.spoke2.id
    spoke3 = azurerm_virtual_network.spoke3.id
  }
}

# Hub to Spokes
module "peering_hub_to_spokes" {
  for_each = local.spokes

  source = "../../modules/hub/azure-vnet-peering"

  name                         = "peer-hub-to-${each.key}"
  resource_group_name          = azurerm_resource_group.hub.name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = each.value

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
}

# Spokes to Hub
module "peering_spokes_to_hub" {
  for_each = local.spokes

  source = "../../modules/hub/azure-vnet-peering"

  name                         = "peer-${each.key}-to-hub"
  resource_group_name          = azurerm_resource_group.spoke[each.key].name
  virtual_network_name         = each.value.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  use_remote_gateways          = var.use_hub_gateway
}
```

### Spoke-to-Spoke Communication

For spokes to communicate:

1. **Option 1**: Route through hub (recommended)
   - Enable `allow_forwarded_traffic` on all peerings
   - Configure route tables to send spoke traffic to hub
   - Use Azure Firewall or NVA in hub

2. **Option 2**: Direct peering between spokes
   - Create peering between each spoke pair
   - Not scalable for many spokes

## Cross-Subscription Peering

```hcl
# In Hub subscription
provider "azurerm" {
  alias           = "hub"
  subscription_id = var.hub_subscription_id
}

# In Spoke subscription
provider "azurerm" {
  alias           = "spoke"
  subscription_id = var.spoke_subscription_id
}

# Hub to Spoke
module "peering_hub_to_spoke" {
  source = "../../modules/hub/azure-vnet-peering"
  providers = {
    azurerm = azurerm.hub
  }

  name                      = "peer-hub-to-spoke"
  resource_group_name       = var.hub_rg_name
  virtual_network_name      = var.hub_vnet_name
  remote_virtual_network_id = var.spoke_vnet_id  # Full ARM ID including subscription

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

# Spoke to Hub (in spoke subscription)
module "peering_spoke_to_hub" {
  source = "../../modules/hub/azure-vnet-peering"
  providers = {
    azurerm = azurerm.spoke
  }

  name                      = "peer-spoke-to-hub"
  resource_group_name       = var.spoke_rg_name
  virtual_network_name      = var.spoke_vnet_name
  remote_virtual_network_id = var.hub_vnet_id  # Full ARM ID including subscription

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  use_remote_gateways          = true
}
```

## Global VNet Peering

Cross-region peering:

```hcl
module "peering_eastus_to_westus" {
  source = "../../modules/hub/azure-vnet-peering"

  name                         = "peer-eastus-to-westus"
  resource_group_name          = azurerm_resource_group.eastus.name
  virtual_network_name         = azurerm_virtual_network.eastus.name
  remote_virtual_network_id    = azurerm_virtual_network.westus.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = false  # Usually no forwarding for global peering
}
```

**Global Peering Limits**:
- Higher latency than regional
- Additional cost per GB transferred
- Same security and encryption

## Troubleshooting

### Peering in "Initiated" State

Both sides of peering must be configured. If one side is missing, status shows "Initiated".

### Cannot Use Remote Gateway

Check:
1. Remote VNet has provisioned VPN/ER gateway
2. Remote peering has `allow_gateway_transit = true`
3. Local peering has `use_remote_gateways = true`
4. No address space overlap

### Address Space Overlap

VNets cannot peer if address spaces overlap. Solution:
- Change address space (destructive)
- Use different VNets

### Service Chaining Not Working

For spoke-to-spoke via hub:
1. Enable `allow_forwarded_traffic` on all peerings
2. Add route tables on spokes pointing to hub
3. Enable IP forwarding on hub NVA/Firewall

## Best Practices

1. **Bidirectional**: Always create both peerings
2. **Naming**: Use descriptive names (e.g., `peer-hub-to-spoke1`)
3. **Hub Gateway**: Only one hub should have `allow_gateway_transit = true`
4. **Forwarded Traffic**: Enable for hub-spoke topologies
5. **Triggers**: Use for automatic recreation on changes
6. **Documentation**: Document peering topology
7. **Monitoring**: Enable diagnostic logs

## Cost

- Regional peering: Ingress free, egress $0.01/GB
- Global peering: Both directions $0.035/GB
- No additional cost for peering itself

## See Also

- [Basic Example](./examples/basic/)
- [Advanced Hub-Spoke Example](./examples/advanced/)
- [Azure VNet Peering Documentation](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview)

## License

MIT License - see [LICENSE](../../../LICENSE) for details.
