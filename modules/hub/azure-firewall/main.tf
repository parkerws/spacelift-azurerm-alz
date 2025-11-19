locals {
  # Determine if we need to create public IPs
  create_public_ips = length(var.ip_configurations) == 0 && var.sku_name == "AZFW_VNet"

  # Generate IP configuration names if creating public IPs
  ip_config_names = local.create_public_ips ? [
    for i in range(var.public_ip_count) : "ipconfig-${i + 1}"
  ] : []

  # Build IP configurations from created public IPs
  generated_ip_configurations = local.create_public_ips ? [
    for i, name in local.ip_config_names : {
      name                 = name
      subnet_id            = i == 0 ? var.subnet_id : null
      public_ip_address_id = azurerm_public_ip.firewall[i].id
    }
  ] : []

  # Use provided or generated IP configurations
  final_ip_configurations = length(var.ip_configurations) > 0 ? var.ip_configurations : local.generated_ip_configurations
}

# Create public IPs when not explicitly provided
resource "azurerm_public_ip" "firewall" {
  count = local.create_public_ips ? var.public_ip_count : 0

  name                = "${var.name}-pip-${count.index + 1}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.public_ip_sku
  allocation_method   = var.public_ip_allocation_method
  zones               = var.zones
  public_ip_prefix_id = var.public_ip_prefix_id

  tags = merge(
    var.tags,
    {
      Purpose = "AzureFirewall"
    }
  )
}

# Azure Firewall
resource "azurerm_firewall" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = var.sku_name
  sku_tier            = var.sku_tier
  firewall_policy_id  = var.firewall_policy_id
  threat_intel_mode   = var.threat_intel_mode
  zones               = var.zones
  private_ip_ranges   = var.private_ip_ranges
  dns_servers         = var.dns_servers

  # DNS proxy configuration
  dynamic "dns" {
    for_each = var.dns_proxy_enabled || length(var.dns_servers) > 0 ? [1] : []

    content {
      proxy_enabled = var.dns_proxy_enabled
      servers       = var.dns_servers
    }
  }

  # IP configurations (AZFW_VNet only)
  dynamic "ip_configuration" {
    for_each = var.sku_name == "AZFW_VNet" ? local.final_ip_configurations : []

    content {
      name                 = ip_configuration.value.name
      subnet_id            = ip_configuration.value.subnet_id
      public_ip_address_id = ip_configuration.value.public_ip_address_id
    }
  }

  # Management IP configuration (for forced tunneling or Basic SKU)
  dynamic "management_ip_configuration" {
    for_each = var.management_ip_configuration != null ? [var.management_ip_configuration] : []

    content {
      name                 = management_ip_configuration.value.name
      subnet_id            = management_ip_configuration.value.subnet_id
      public_ip_address_id = management_ip_configuration.value.public_ip_address_id
    }
  }

  # Virtual Hub configuration (AZFW_Hub only)
  dynamic "virtual_hub" {
    for_each = var.sku_name == "AZFW_Hub" && var.virtual_hub_id != null ? [1] : []

    content {
      virtual_hub_id = var.virtual_hub_id
    }
  }

  tags = var.tags

  lifecycle {
    # Prevent accidental deletion
    prevent_destroy = false

    # IP configurations must be created before being referenced
    create_before_destroy = false
  }

  depends_on = [
    azurerm_public_ip.firewall
  ]
}
