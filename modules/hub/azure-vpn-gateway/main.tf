locals {
  # Determine number of public IPs needed
  public_ip_count = var.active_active ? 2 : 1

  # Generate IP configuration names
  ip_config_names = var.active_active ? ["ipconfig-primary", "ipconfig-secondary"] : ["ipconfig-primary"]

  # Use provided or created public IPs
  public_ip_ids = var.create_public_ips ? azurerm_public_ip.gateway[*].id : var.public_ip_address_ids
}

# Create public IPs if not provided
resource "azurerm_public_ip" "gateway" {
  count = var.create_public_ips ? local.public_ip_count : 0

  name                = "${var.name}-pip-${count.index + 1}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.public_ip_sku
  allocation_method   = var.public_ip_allocation_method
  edge_zone           = var.edge_zone

  tags = merge(
    var.tags,
    {
      Purpose = "VPNGateway"
    }
  )
}

# Virtual Network Gateway
resource "azurerm_virtual_network_gateway" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  type                = var.type
  vpn_type            = var.type == "Vpn" ? var.vpn_type : null
  sku                 = var.sku
  generation          = var.generation
  enable_bgp          = var.enable_bgp
  active_active       = var.active_active
  private_ip_address_allocation = var.private_ip_address_allocation
  default_local_network_gateway_id = var.default_local_network_gateway_id
  edge_zone           = var.edge_zone

  # Primary IP configuration
  ip_configuration {
    name                          = local.ip_config_names[0]
    public_ip_address_id          = local.public_ip_ids[0]
    private_ip_address_allocation = var.private_ip_address_allocation
    subnet_id                     = var.subnet_id
  }

  # Secondary IP configuration (active-active only)
  dynamic "ip_configuration" {
    for_each = var.active_active ? [1] : []

    content {
      name                          = local.ip_config_names[1]
      public_ip_address_id          = local.public_ip_ids[1]
      private_ip_address_allocation = var.private_ip_address_allocation
      subnet_id                     = var.subnet_id
    }
  }

  # BGP settings
  dynamic "bgp_settings" {
    for_each = var.enable_bgp && var.bgp_settings != null ? [var.bgp_settings] : []

    content {
      asn             = bgp_settings.value.asn
      peering_address = bgp_settings.value.peering_address
      peer_weight     = bgp_settings.value.peer_weight
    }
  }

  # Point-to-site VPN client configuration
  dynamic "vpn_client_configuration" {
    for_each = var.vpn_client_configuration != null ? [var.vpn_client_configuration] : []

    content {
      address_space         = vpn_client_configuration.value.address_space
      vpn_client_protocols  = vpn_client_configuration.value.vpn_client_protocols
      aad_tenant            = vpn_client_configuration.value.aad_tenant
      aad_audience          = vpn_client_configuration.value.aad_audience
      aad_issuer            = vpn_client_configuration.value.aad_issuer
      radius_server_address = vpn_client_configuration.value.radius_server_address
      radius_server_secret  = vpn_client_configuration.value.radius_server_secret
      vpn_auth_types        = vpn_client_configuration.value.vpn_auth_types

      dynamic "root_certificate" {
        for_each = vpn_client_configuration.value.root_certificate

        content {
          name             = root_certificate.value.name
          public_cert_data = root_certificate.value.public_cert_data
        }
      }

      dynamic "revoked_certificate" {
        for_each = vpn_client_configuration.value.revoked_certificate

        content {
          name       = revoked_certificate.value.name
          thumbprint = revoked_certificate.value.thumbprint
        }
      }
    }
  }

  # Custom routes
  dynamic "custom_route" {
    for_each = var.custom_route != null ? [var.custom_route] : []

    content {
      address_prefixes = custom_route.value.address_prefixes
    }
  }

  tags = var.tags

  lifecycle {
    # Prevent accidental deletion
    prevent_destroy = false
  }

  depends_on = [
    azurerm_public_ip.gateway
  ]
}
