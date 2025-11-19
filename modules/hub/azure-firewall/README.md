# Azure Firewall Module

Terraform module for creating Azure Firewall with support for multiple public IPs, Premium SKU features, forced tunneling, and DNS proxy.

## Features

- ✅ Multiple public IP support (up to 100 IPs)
- ✅ Premium and Standard SKU support
- ✅ Forced tunneling configuration
- ✅ DNS proxy and custom DNS servers
- ✅ Threat intelligence-based filtering
- ✅ Availability Zones support
- ✅ Public IP prefix integration
- ✅ Virtual WAN Hub support (AZFW_Hub)
- ✅ SNAT private IP range configuration
- ✅ Automatic or explicit IP configuration

## Usage

### Basic Example - Single Public IP

```hcl
module "firewall" {
  source = "../../modules/hub/azure-firewall"

  name                = "fw-hub-prod-001"
  resource_group_name = azurerm_resource_group.hub.name
  location            = "eastus"

  sku_name           = "AZFW_VNet"
  sku_tier           = "Standard"
  firewall_policy_id = azurerm_firewall_policy.main.id

  # Automatically create 1 public IP
  subnet_id       = azurerm_subnet.firewall.id
  public_ip_count = 1

  threat_intel_mode = "Alert"

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Multi-Public-IP Configuration

```hcl
# Create a public IP prefix for consistent allocation
resource "azurerm_public_ip_prefix" "firewall" {
  name                = "pip-prefix-firewall"
  resource_group_name = azurerm_resource_group.hub.name
  location            = "eastus"
  prefix_length       = 29 # Provides 8 IPs
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
}

module "firewall" {
  source = "../../modules/hub/azure-firewall"

  name                = "fw-hub-prod-001"
  resource_group_name = azurerm_resource_group.hub.name
  location            = "eastus"

  sku_name           = "AZFW_VNet"
  sku_tier           = "Premium"
  firewall_policy_id = azurerm_firewall_policy.premium.id

  # Multiple public IPs for high throughput
  subnet_id           = azurerm_subnet.firewall.id
  public_ip_count     = 8
  public_ip_prefix_id = azurerm_public_ip_prefix.firewall.id

  # Availability zones for high availability
  zones = ["1", "2", "3"]

  dns_proxy_enabled = true
  threat_intel_mode = "Deny"

  tags = {
    Environment = "Production"
    Throughput  = "High"
  }
}
```

### Forced Tunneling

```hcl
# Create management subnet
resource "azurerm_subnet" "firewall_management" {
  name                 = "AzureFirewallManagementSubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.1.0/26"]
}

# Create management public IP
resource "azurerm_public_ip" "firewall_management" {
  name                = "pip-fw-management"
  resource_group_name = azurerm_resource_group.hub.name
  location            = "eastus"
  sku                 = "Standard"
  allocation_method   = "Static"
}

module "firewall" {
  source = "../../modules/hub/azure-firewall"

  name                = "fw-forced-tunnel-001"
  resource_group_name = azurerm_resource_group.hub.name
  location            = "eastus"

  sku_name           = "AZFW_VNet"
  sku_tier           = "Standard"
  firewall_policy_id = azurerm_firewall_policy.main.id

  # Regular configuration
  subnet_id       = azurerm_subnet.firewall.id
  public_ip_count = 1

  # Management IP for forced tunneling
  management_ip_configuration = {
    name                 = "mgmt-ipconfig"
    subnet_id            = azurerm_subnet.firewall_management.id
    public_ip_address_id = azurerm_public_ip.firewall_management.id
  }

  tags = {
    Pattern = "ForcedTunneling"
  }
}
```

### Premium SKU with Advanced Features

```hcl
resource "azurerm_firewall_policy" "premium" {
  name                = "fw-policy-premium"
  resource_group_name = azurerm_resource_group.hub.name
  location            = "eastus"
  sku                 = "Premium"

  threat_intelligence_mode = "Deny"

  dns {
    proxy_enabled = true
  }

  intrusion_detection {
    mode = "Deny"
  }

  tls_certificate {
    key_vault_secret_id = azurerm_key_vault_certificate.ca.secret_id
    name                = "ca-cert"
  }
}

module "firewall" {
  source = "../../modules/hub/azure-firewall"

  name                = "fw-premium-001"
  resource_group_name = azurerm_resource_group.hub.name
  location            = "eastus"

  sku_name           = "AZFW_VNet"
  sku_tier           = "Premium"
  firewall_policy_id = azurerm_firewall_policy.premium.id

  subnet_id       = azurerm_subnet.firewall.id
  public_ip_count = 4
  zones           = ["1", "2", "3"]

  dns_proxy_enabled = true
  threat_intel_mode = "Deny"

  # SNAT private IP ranges (avoid SNATing internal traffic)
  private_ip_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]

  tags = {
    SKU = "Premium"
  }
}
```

### Explicit IP Configurations

```hcl
# Pre-created public IPs
resource "azurerm_public_ip" "fw_primary" {
  name                = "pip-fw-primary"
  resource_group_name = azurerm_resource_group.hub.name
  location            = "eastus"
  sku                 = "Standard"
  allocation_method   = "Static"
  zones               = ["1", "2", "3"]
}

resource "azurerm_public_ip" "fw_secondary" {
  name                = "pip-fw-secondary"
  resource_group_name = azurerm_resource_group.hub.name
  location            = "eastus"
  sku                 = "Standard"
  allocation_method   = "Static"
  zones               = ["1", "2", "3"]
}

module "firewall" {
  source = "../../modules/hub/azure-firewall"

  name                = "fw-explicit-ips-001"
  resource_group_name = azurerm_resource_group.hub.name
  location            = "eastus"

  sku_name           = "AZFW_VNet"
  sku_tier           = "Standard"
  firewall_policy_id = azurerm_firewall_policy.main.id

  # Explicitly provided IP configurations
  ip_configurations = [
    {
      name                 = "primary-ipconfig"
      subnet_id            = azurerm_subnet.firewall.id
      public_ip_address_id = azurerm_public_ip.fw_primary.id
    },
    {
      name                 = "secondary-ipconfig"
      subnet_id            = null # Only first config needs subnet
      public_ip_address_id = azurerm_public_ip.fw_secondary.id
    }
  ]

  dns_proxy_enabled = true
  threat_intel_mode = "Alert"
  zones             = ["1", "2", "3"]

  tags = {
    IPManagement = "Explicit"
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
| [azurerm_firewall.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall) | resource |
| [azurerm_public_ip.firewall](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the Azure Firewall. | `string` | n/a | yes |
| resource_group_name | The name of the resource group. | `string` | n/a | yes |
| location | The location/region. | `string` | n/a | yes |
| sku_name | SKU name (AZFW_Hub or AZFW_VNet). | `string` | `"AZFW_VNet"` | no |
| sku_tier | SKU tier (Premium, Standard, Basic). | `string` | `"Standard"` | no |
| firewall_policy_id | The ID of the Firewall Policy. | `string` | `null` | no |
| ip_configurations | List of IP configurations. | `list(object({...}))` | `[]` | no |
| management_ip_configuration | Management IP configuration for forced tunneling. | `object({...})` | `null` | no |
| virtual_hub_id | Virtual Hub ID (for AZFW_Hub SKU). | `string` | `null` | no |
| public_ip_count | Number of public IPs to create (1-100). | `number` | `1` | no |
| dns_servers | List of DNS servers. | `list(string)` | `[]` | no |
| dns_proxy_enabled | Enable DNS proxy. | `bool` | `false` | no |
| threat_intel_mode | Threat intelligence mode (Alert, Deny, Off). | `string` | `"Alert"` | no |
| zones | Availability zones. | `list(string)` | `null` | no |
| private_ip_ranges | SNAT private IP ranges. | `list(string)` | `[]` | no |
| subnet_id | AzureFirewallSubnet ID (for AZFW_VNet). | `string` | `null` | no |
| public_ip_prefix_id | Public IP Prefix ID. | `string` | `null` | no |
| tags | Tags to assign. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Azure Firewall. |
| name | The name of the Azure Firewall. |
| private_ip_address | The private IP address of the Azure Firewall. |
| public_ip_addresses | The public IP addresses (auto-created). |
| public_ip_ids | The IDs of public IPs (auto-created). |
| ip_configurations | The IP configurations. |
| virtual_hub_private_ip_address | Private IP when deployed in Virtual WAN hub. |
| virtual_hub_public_ip_addresses | Public IPs when deployed in Virtual WAN hub. |
| threat_intel_mode | The threat intelligence mode. |
| sku_name | The SKU name. |
| sku_tier | The SKU tier. |
| zones | The availability zones. |
| firewall_policy_id | The Firewall Policy ID. |
| dns_servers | The DNS servers configured. |
| this | The full Azure Firewall resource object. |

## Examples

See the [examples](./examples/) directory for complete examples:

- [Basic](./examples/basic/) - Single public IP firewall
- [Advanced](./examples/advanced/) - Multi-IP, Premium SKU, forced tunneling, explicit IPs

## SKU Options

### SKU Name

- **AZFW_VNet**: Deploy in a virtual network (traditional deployment)
- **AZFW_Hub**: Deploy in a Virtual WAN hub (vWAN integration)

### SKU Tier

- **Basic**: Cost-optimized for SMB (supports up to 250 Mbps)
- **Standard**: General purpose (supports up to 30 Gbps)
- **Premium**: Advanced security features (IDPS, TLS inspection, URL filtering)

## Multi-Public-IP Benefits

Adding multiple public IPs to Azure Firewall:

1. **Increased Throughput**: Each IP adds ~30 Gbps SNAT capacity
2. **Connection Scalability**: 64,000 ports per IP (SNAT ports)
3. **Service Separation**: Different services can use different public IPs
4. **Disaster Recovery**: IP-level redundancy

**Recommended IP Counts**:
- Small deployments: 1-2 IPs
- Medium deployments: 3-5 IPs
- Large deployments: 5-10 IPs
- Maximum: 100 IPs

## Forced Tunneling

Forced tunneling sends all internet-bound traffic through on-premises before going to the internet.

**Requirements**:
- `AzureFirewallManagementSubnet` (/26 minimum)
- Management public IP
- `management_ip_configuration` configured

**Use Cases**:
- Regulatory compliance requiring on-prem inspection
- Centralized internet egress logging
- Integration with on-prem security tools

## DNS Proxy

When DNS proxy is enabled:
- Firewall acts as DNS server for VMs
- Firewall queries DNS on behalf of VMs
- Enables FQDN filtering in network rules
- Required for TLS inspection (Premium)

**Configuration**:
```hcl
dns_proxy_enabled = true
dns_servers       = ["10.0.0.4", "10.0.0.5"] # Optional custom DNS
```

VMs should use firewall's private IP as DNS server.

## Threat Intelligence

Three modes available:

- **Alert**: Log threats but allow traffic
- **Deny**: Block and log threats
- **Off**: Disable threat intelligence

Microsoft maintains threat intelligence feeds updated in real-time.

## SNAT Private IP Ranges

By default, Azure Firewall SNATs all outbound traffic. Configure `private_ip_ranges` to exclude internal ranges:

```hcl
private_ip_ranges = [
  "10.0.0.0/8",      # RFC 1918
  "172.16.0.0/12",   # RFC 1918
  "192.168.0.0/16",  # RFC 1918
  "100.64.0.0/10"    # RFC 6598 (Carrier-grade NAT)
]
```

## Important Notes

### Subnet Requirements

- **AzureFirewallSubnet**: Minimum /26 (64 IPs), recommended /25
- **AzureFirewallManagementSubnet**: Minimum /26 (for forced tunneling)
- Subnet names are **case-sensitive** and **reserved**

### Public IP Requirements

- SKU: Must be **Standard**
- Allocation: Must be **Static**
- Zones: Must match firewall zones (if using zones)

### Availability Zones

- Supported zones: 1, 2, 3
- All public IPs must be in same zones as firewall
- Zone-redundant recommended for production

### Firewall Policy

- Premium SKU requires Premium policy
- Standard SKU can use Standard or Basic policy
- Policy can be shared across multiple firewalls

### IP Configuration Limits

- Minimum: 1 IP configuration
- Maximum: 100 IP configurations
- First IP configuration must include `subnet_id`
- Subsequent IPs: `subnet_id` must be `null`

## Hub-and-Spoke Best Practices

1. **Single Firewall per Hub**: One firewall per hub VNet
2. **Multiple IPs**: Use 3-5 IPs for production hubs
3. **Availability Zones**: Always use zones for production
4. **DNS Proxy**: Enable for FQDN-based rules
5. **Threat Intel**: Use "Deny" mode for production
6. **SNAT Ranges**: Configure to avoid SNATing internal traffic
7. **Monitoring**: Enable diagnostic logs and metrics

## Cost Optimization

- **Basic SKU**: 80% cheaper than Standard (SMB use cases)
- **Public IP Count**: Only add IPs as needed
- **Availability Zones**: Slightly higher cost but worth it
- **Premium Features**: Only use if IDPS/TLS inspection needed
- **Firewall Policy**: Share across multiple firewalls

## Troubleshooting

### Firewall Not Routing Traffic

Check:
1. Route tables point to firewall private IP
2. Firewall policy has allow rules
3. NSGs don't block traffic
4. IP forwarding enabled on firewall

### SNAT Port Exhaustion

Solutions:
1. Add more public IPs
2. Configure SNAT private IP ranges
3. Use NAT Gateway for specific subnets

### DNS Not Working

Check:
1. `dns_proxy_enabled = true`
2. VMs point to firewall private IP as DNS
3. Firewall can reach DNS servers

## Spacelift Integration

This module includes `.spacelift/config.yml` for:
- Module registry registration
- Automated testing
- Policy attachment

## Contributing

See [CONTRIBUTING.md](../../../CONTRIBUTING.md) for development guidelines.

## License

MIT License - see [LICENSE](../../../LICENSE) for details.
