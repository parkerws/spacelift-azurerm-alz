resource "azurerm_route_table" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  disable_bgp_route_propagation = var.disable_bgp_route_propagation

  tags = var.tags

  lifecycle {
    # Prevent accidental deletion of route tables
    prevent_destroy = false
  }
}

# Create routes as separate resources
# This approach is recommended over inline routes for better flexibility
resource "azurerm_route" "this" {
  for_each = { for route in var.routes : route.name => route }

  name                   = each.value.name
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.this.name
  address_prefix         = each.value.address_prefix
  next_hop_type          = each.value.next_hop_type
  next_hop_in_ip_address = each.value.next_hop_in_ip_address
}
