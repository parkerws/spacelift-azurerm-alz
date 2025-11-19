# Azure VPN Gateway Module

Terraform module for creating Azure VPN Gateway with support for site-to-site, point-to-site, BGP, and active-active configurations.

## Features

- ✅ Site-to-site (S2S) VPN connectivity
- ✅ Point-to-site (P2S) VPN for remote users
- ✅ Active-active mode for high availability
- ✅ BGP support for dynamic routing
- ✅ Azure AD authentication for P2S
- ✅ Certificate-based authentication
- ✅ Generation1 and Generation2 support
- ✅ Multiple SKU options (VpnGw1-VpnGw5, with AZ variants)

## Usage

### Basic Site-to-Site VPN

```hcl
module "vpn_gateway" {
  source = "../../modules/hub/azure-vpn-gateway"

  name                = "vng-hub-prod-001"
  resource_group_name = azurerm_resource_group.hub.name
  location            = "eastus"

  type       = "Vpn"
  vpn_type   = "RouteBased"
  sku        = "VpnGw1"
  generation = "Generation2"

  subnet_id         = azurerm_subnet.gateway.id
  create_public_ips = true

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Active-Active with BGP

```hcl
module "vpn_gateway" {
  source = "../../modules/hub/azure-vpn-gateway"

  name                = "vng-hub-prod-001"
  resource_group_name = azurerm_resource_group.hub.name
  location            = "eastus"

  type          = "Vpn"
  vpn_type      = "RouteBased"
  sku           = "VpnGw2"
  generation    = "Generation2"
  active_active = true
  enable_bgp    = true

  subnet_id         = azurerm_subnet.gateway.id
  create_public_ips = true

  bgp_settings = {
    asn         = 65515
    peer_weight = 0
  }

  tags = {
    Pattern = "ActiveActive"
  }
}
```

### Point-to-Site with Certificate Auth

```hcl
module "vpn_gateway" {
  source = "../../modules/hub/azure-vpn-gateway"

  name                = "vng-hub-p2s-001"
  resource_group_name = azurerm_resource_group.hub.name
  location            = "eastus"

  type       = "Vpn"
  vpn_type   = "RouteBased"
  sku        = "VpnGw1"
  generation = "Generation2"

  subnet_id         = azurerm_subnet.gateway.id
  create_public_ips = true

  vpn_client_configuration = {
    address_space        = ["172.16.0.0/24"]
    vpn_client_protocols = ["OpenVPN", "IkeV2"]

    root_certificate = [
      {
        name             = "RootCert"
        public_cert_data = file("root-cert.cer")
      }
    ]

    revoked_certificate = []
  }

  tags = {
    Pattern = "Point-to-Site"
  }
}
```

### Point-to-Site with Azure AD

```hcl
module "vpn_gateway" {
  source = "../../modules/hub/azure-vpn-gateway"

  name                = "vng-hub-aad-001"
  resource_group_name = azurerm_resource_group.hub.name
  location            = "eastus"

  type       = "Vpn"
  vpn_type   = "RouteBased"
  sku        = "VpnGw1"
  generation = "Generation2"

  subnet_id         = azurerm_subnet.gateway.id
  create_public_ips = true

  vpn_client_configuration = {
    address_space        = ["172.16.0.0/24"]
    vpn_client_protocols = ["OpenVPN"]
    aad_tenant           = "https://login.microsoftonline.com/${var.tenant_id}"
    aad_audience         = "41b23e61-6c1e-4545-b367-cd054e0ed4b4"
    aad_issuer           = "https://sts.windows.net/${var.tenant_id}/"
    vpn_auth_types       = ["AAD"]

    root_certificate    = []
    revoked_certificate = []
  }

  tags = {
    Auth = "AzureAD"
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
| name | VPN Gateway name | `string` | n/a | yes |
| resource_group_name | Resource group name | `string` | n/a | yes |
| location | Azure region | `string` | n/a | yes |
| subnet_id | GatewaySubnet ID | `string` | n/a | yes |
| type | Gateway type (Vpn or ExpressRoute) | `string` | `"Vpn"` | no |
| vpn_type | VPN type (RouteBased or PolicyBased) | `string` | `"RouteBased"` | no |
| sku | Gateway SKU | `string` | `"VpnGw1"` | no |
| generation | Gateway generation | `string` | `"Generation2"` | no |
| enable_bgp | Enable BGP | `bool` | `false` | no |
| active_active | Enable active-active | `bool` | `false` | no |
| create_public_ips | Auto-create public IPs | `bool` | `true` | no |
| bgp_settings | BGP configuration | `object` | `null` | no |
| vpn_client_configuration | P2S configuration | `object` | `null` | no |
| tags | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | VPN Gateway ID |
| name | VPN Gateway name |
| type | Gateway type |
| sku | Gateway SKU |
| public_ip_addresses | Public IP addresses |
| bgp_settings | BGP settings |
| this | Full resource object |

## SKU Comparison

| SKU | Tunnels | Throughput | BGP | Gen2 | AZ |
|-----|---------|------------|-----|------|-----|
| Basic | 10 | 100 Mbps | No | No | No |
| VpnGw1 | 30 | 650 Mbps | Yes | Yes | No |
| VpnGw2 | 30 | 1 Gbps | Yes | Yes | No |
| VpnGw3 | 30 | 1.25 Gbps | Yes | Yes | No |
| VpnGw4 | 100 | 5 Gbps | Yes | Yes | No |
| VpnGw5 | 100 | 10 Gbps | Yes | Yes | No |
| VpnGw1AZ | 30 | 650 Mbps | Yes | Yes | Yes |
| VpnGw2AZ | 30 | 1 Gbps | Yes | Yes | Yes |
| VpnGw3AZ | 30 | 1.25 Gbps | Yes | Yes | Yes |
| VpnGw4AZ | 100 | 5 Gbps | Yes | Yes | Yes |
| VpnGw5AZ | 100 | 10 Gbps | Yes | Yes | Yes |

## Important Notes

### GatewaySubnet

- Required name: **GatewaySubnet** (case-sensitive)
- Minimum size: /27 (32 addresses)
- Recommended: /26 (64 addresses) or larger
- Cannot have NSG attached

### Active-Active Mode

- Requires 2 public IPs
- Provides 99.99% SLA
- Both tunnels active simultaneously
- Automatic failover

### BGP

- Required for multi-site VPN
- Enables dynamic routing
- Supports route-based failover
- ASN range: 64512-65534 (private), 1-64511 (public)

### Generation

- **Generation1**: Lower cost, older SKUs
- **Generation2**: Better performance, newer features
- Cannot change after creation

### P2S Protocols

- **IkeV2**: Windows, macOS, Linux
- **OpenVPN**: All platforms, modern
- **SSTP**: Windows only (legacy)

## Common Patterns

### Hub VPN Gateway

```hcl
module "hub_vpn" {
  source = "../../modules/hub/azure-vpn-gateway"

  name                = "vng-hub-${var.environment}-${var.location}-001"
  resource_group_name = azurerm_resource_group.hub.name
  location            = var.location

  type          = "Vpn"
  sku           = "VpnGw2AZ"
  generation    = "Generation2"
  active_active = true
  enable_bgp    = true

  subnet_id         = azurerm_subnet.gateway.id
  create_public_ips = true

  bgp_settings = {
    asn = 65515
  }

  tags = merge(var.common_tags, {
    NetworkType = "Hub"
    Purpose     = "SiteToSite"
  })
}
```

### Remote Worker Access

```hcl
module "p2s_vpn" {
  source = "../../modules/hub/azure-vpn-gateway"

  name                = "vng-p2s-${var.environment}-001"
  resource_group_name = azurerm_resource_group.hub.name
  location            = var.location

  type       = "Vpn"
  sku        = "VpnGw1"
  generation = "Generation2"

  subnet_id         = azurerm_subnet.gateway.id
  create_public_ips = true

  vpn_client_configuration = {
    address_space        = [var.p2s_address_space]
    vpn_client_protocols = ["OpenVPN"]
    aad_tenant           = var.aad_tenant_url
    aad_audience         = "41b23e61-6c1e-4545-b367-cd054e0ed4b4"
    aad_issuer           = var.aad_issuer_url
    vpn_auth_types       = ["AAD"]
  }

  tags = merge(var.common_tags, {
    Purpose = "RemoteAccess"
  })
}
```

## Troubleshooting

### Gateway Not Connecting

Check:
1. GatewaySubnet exists and is correctly named
2. Public IPs are Standard SKU
3. Local network gateway configured
4. Shared key matches on both sides
5. NSG not blocking UDP 500/4500

### BGP Not Working

Check:
1. `enable_bgp = true`
2. ASN configured correctly
3. BGP peer IP reachable
4. No IP conflicts with BGP addresses

### P2S Not Connecting

Check:
1. Client certificate installed
2. Root certificate uploaded correctly
3. Address pool not overlapping
4. Client configuration downloaded and installed

## Cost Optimization

- Use Basic SKU for dev/test (not for production)
- Generation2 slightly more expensive but better value
- AZ SKUs cost ~30% more but provide better SLA
- Consider ExpressRoute for high bandwidth needs

## See Also

- [Basic Example](./examples/basic/)
- [Advanced Examples](./examples/advanced/)
- [Azure VPN Gateway Documentation](https://learn.microsoft.com/en-us/azure/vpn-gateway/)

## License

MIT License - see [LICENSE](../../../LICENSE) for details.
