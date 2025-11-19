resource "azurerm_network_security_group" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = var.tags

  lifecycle {
    # Prevent accidental deletion of NSGs
    prevent_destroy = false
  }
}

# Create security rules as separate resources
# This approach is recommended over inline rules for better flexibility
resource "azurerm_network_security_rule" "this" {
  for_each = { for rule in var.security_rules : rule.name => rule }

  name                        = each.value.name
  description                 = each.value.description
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.this.name

  protocol                   = each.value.protocol
  source_port_range          = each.value.source_port_range
  source_port_ranges         = each.value.source_port_ranges
  destination_port_range     = each.value.destination_port_range
  destination_port_ranges    = each.value.destination_port_ranges
  source_address_prefix      = each.value.source_address_prefix
  source_address_prefixes    = each.value.source_address_prefixes
  destination_address_prefix = each.value.destination_address_prefix
  destination_address_prefixes = each.value.destination_address_prefixes

  source_application_security_group_ids      = each.value.source_application_security_group_ids
  destination_application_security_group_ids = each.value.destination_application_security_group_ids

  access    = each.value.access
  priority  = each.value.priority
  direction = each.value.direction
}
