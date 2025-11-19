# Azure Bastion Module

Terraform module for creating Azure Bastion for secure RDP/SSH access to VMs without exposing public IPs.

## Features

- ✅ Secure RDP/SSH access without public IPs on VMs
- ✅ Basic, Standard, and Premium SKU support
- ✅ File transfer (Standard/Premium)
- ✅ IP-based connection (Standard/Premium)
- ✅ Shareable links (Standard/Premium)
- ✅ Native client tunneling (Standard/Premium)
- ✅ Kerberos authentication (Standard/Premium)
- ✅ Availability Zones support
- ✅ Scalable (2-50 instances)

## Usage

### Basic Bastion

```hcl
module "bastion" {
  source = "../../modules/hub/azure-bastion"

  name                = "bastion-hub-prod-001"
  resource_group_name = azurerm_resource_group.hub.name
  location            = "eastus"

  sku       = "Basic"
  subnet_id = azurerm_subnet.bastion.id

  create_public_ip = true

  tags = {
    Environment = "Production"
  }
}
```

### Standard Bastion with Features

```hcl
module "bastion" {
  source = "../../modules/hub/azure-bastion"

  name                = "bastion-hub-prod-001"
  resource_group_name = azurerm_resource_group.hub.name
  location            = "eastus"

  sku         = "Standard"
  scale_units = 4
  subnet_id   = azurerm_subnet.bastion.id

  create_public_ip = true

  # Enable features
  copy_paste_enabled     = true
  file_copy_enabled      = true
  ip_connect_enabled     = true
  tunneling_enabled      = true
  shareable_link_enabled = false

  zones = ["1", "2", "3"]

  tags = {
    Environment = "Production"
  }
}
```

### Premium Bastion (All Features)

```hcl
module "bastion" {
  source = "../../modules/hub/azure-bastion"

  name                = "bastion-hub-prod-001"
  resource_group_name = azurerm_resource_group.hub.name
  location            = "eastus"

  sku         = "Premium"
  scale_units = 10
  subnet_id   = azurerm_subnet.bastion.id

  create_public_ip = true

  # Enable all features
  copy_paste_enabled     = true
  file_copy_enabled      = true
  ip_connect_enabled     = true
  tunneling_enabled      = true
  shareable_link_enabled = true
  kerberos_enabled       = true

  zones = ["1", "2", "3"]

  tags = {
    Environment = "Production"
    SKU         = "Premium"
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
| name | Bastion Host name | `string` | n/a | yes |
| resource_group_name | Resource group name | `string` | n/a | yes |
| location | Azure region | `string` | n/a | yes |
| subnet_id | AzureBastionSubnet ID | `string` | n/a | yes |
| sku | Bastion SKU (Basic, Standard, Premium) | `string` | `"Standard"` | no |
| scale_units | Number of instances (2-50) | `number` | `2` | no |
| create_public_ip | Auto-create public IP | `bool` | `true` | no |
| copy_paste_enabled | Enable copy/paste | `bool` | `true` | no |
| file_copy_enabled | Enable file copy | `bool` | `false` | no |
| ip_connect_enabled | Enable IP connect | `bool` | `false` | no |
| shareable_link_enabled | Enable shareable links | `bool` | `false` | no |
| tunneling_enabled | Enable native client | `bool` | `false` | no |
| kerberos_enabled | Enable Kerberos auth | `bool` | `false` | no |
| zones | Availability zones | `list(string)` | `null` | no |
| tags | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | Bastion Host ID |
| name | Bastion Host name |
| dns_name | Bastion FQDN |
| public_ip_address | Public IP address |
| sku | Bastion SKU |
| scale_units | Number of instances |
| features | Enabled features |
| this | Full resource object |

## SKU Comparison

| Feature | Basic | Standard | Premium |
|---------|-------|----------|---------|
| **Price ($/hour)** | ~$0.19 | ~$0.29 | ~$0.60 |
| **Max Sessions** | 25 | 50+ | 200+ |
| **Copy/Paste** | ✅ | ✅ | ✅ |
| **File Transfer** | ❌ | ✅ | ✅ |
| **IP Connect** | ❌ | ✅ | ✅ |
| **Shareable Links** | ❌ | ✅ | ✅ |
| **Native Client** | ❌ | ✅ | ✅ |
| **Kerberos** | ❌ | ❌ | ✅ |
| **Private-only VNet** | ❌ | ❌ | ✅ |
| **Scaling** | No | 2-50 units | 2-50 units |
| **Availability Zones** | ❌ | ✅ | ✅ |

## Important Notes

### AzureBastionSubnet

- **Name**: Must be `AzureBastionSubnet` (case-sensitive)
- **Size**: Minimum /26 (64 addresses)
- **NSG**: Can attach NSG with specific rules
- **No other resources**: Cannot deploy other resources in subnet

### Public IP

- **SKU**: Must be Standard
- **Allocation**: Must be Static
- **Zones**: Must match Bastion zones if using AZ

### Scale Units

- **Minimum**: 2 instances
- **Maximum**: 50 instances
- **Capacity**: Each unit supports ~20-25 concurrent connections
- **Cost**: Billed per unit per hour

### Features

**Copy/Paste**: Clipboard sharing between local and remote
**File Transfer**: Upload/download files up to 1GB
**IP Connect**: Connect using private IP instead of VM name
**Shareable Links**: Generate shareable URLs for Bastion access
**Native Client**: Use native RDP/SSH clients instead of browser
**Kerberos**: Windows integrated authentication

## Common Patterns

### Hub Bastion for Spoke Access

```hcl
module "hub_bastion" {
  source = "../../modules/hub/azure-bastion"

  name                = "bastion-hub-${var.environment}-${var.location}-001"
  resource_group_name = azurerm_resource_group.hub.name
  location            = var.location

  sku         = "Standard"
  scale_units = var.bastion_scale_units
  subnet_id   = azurerm_subnet.bastion.id

  create_public_ip = true

  copy_paste_enabled = true
  file_copy_enabled  = true
  tunneling_enabled  = true
  ip_connect_enabled = true

  zones = ["1", "2", "3"]

  tags = merge(var.common_tags, {
    NetworkType = "Hub"
    Purpose     = "SecureAccess"
  })
}
```

## Connectivity

### Connect via Azure Portal

1. Navigate to VM → Connect → Bastion
2. Enter credentials
3. Connect in browser

### Connect via Native Client (Standard/Premium with Tunneling)

```bash
# Windows
az network bastion rdp --name bastion-hub-prod-001 \
  --resource-group rg-hub --target-resource-id <vm-id>

# Linux
az network bastion ssh --name bastion-hub-prod-001 \
  --resource-group rg-hub --target-resource-id <vm-id> \
  --auth-type password
```

### Shareable Links (Standard/Premium)

```bash
az network bastion create-shareable-link \
  --name bastion-hub-prod-001 \
  --resource-group rg-hub \
  --vms <vm-id>
```

## Security Best Practices

1. **Disable Shareable Links**: Often disabled for compliance
2. **Use Availability Zones**: For production deployments
3. **Enable Only Needed Features**: Minimize attack surface
4. **NSG Rules**: Restrict inbound to Bastion subnet
5. **Monitor Access**: Enable diagnostic logs
6. **Just-in-Time Access**: Combine with Azure JIT VM access

## Cost Optimization

- **Basic**: Dev/test environments (~75% cheaper)
- **Standard**: Production with file transfer needs
- **Premium**: Only if Kerberos or private VNet needed
- **Scale Units**: Start with 2, increase based on usage
- **Zones**: Adds ~20% cost but provides 99.99% SLA

## Troubleshooting

### Cannot Connect

Check:
1. AzureBastionSubnet exists and is /26 or larger
2. Public IP is Standard SKU and Static
3. VM has private IP
4. NSG allows traffic from AzureBastionSubnet
5. VM is running

### File Transfer Not Working

Check:
1. SKU is Standard or Premium
2. `file_copy_enabled = true`
3. File size < 1GB
4. Browser supports file transfer

### Native Client Not Working

Check:
1. SKU is Standard or Premium
2. `tunneling_enabled = true`
3. Azure CLI version >= 2.32
4. Target VM is running

## See Also

- [Basic Example](./examples/basic/)
- [Advanced Examples](./examples/advanced/)
- [Azure Bastion Documentation](https://learn.microsoft.com/en-us/azure/bastion/)

## License

MIT License - see [LICENSE](../../../LICENSE) for details.
