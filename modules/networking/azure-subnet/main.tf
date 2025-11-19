resource "azurerm_subnet" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes    = var.address_prefixes

  default_outbound_access_enabled              = var.default_outbound_access_enabled
  private_endpoint_network_policies            = var.private_endpoint_network_policies
  private_link_service_network_policies_enabled = var.private_link_service_network_policies_enabled
  service_endpoints                            = var.service_endpoints
  service_endpoint_policy_ids                  = var.service_endpoint_policy_ids

  dynamic "delegation" {
    for_each = var.delegations

    content {
      name = delegation.value.name

      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }

  lifecycle {
    # Prevent accidental deletion of subnets
    prevent_destroy = false
  }
}
