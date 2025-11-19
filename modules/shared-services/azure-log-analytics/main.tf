resource "azurerm_log_analytics_workspace" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  retention_in_days   = var.retention_in_days
  daily_quota_gb      = var.daily_quota_gb

  internet_ingestion_enabled          = var.internet_ingestion_enabled
  internet_query_enabled              = var.internet_query_enabled
  reservation_capacity_in_gb_per_day  = var.sku == "CapacityReservation" ? var.reservation_capacity_in_gb_per_day : null
  local_authentication_disabled       = var.local_authentication_disabled
  cmk_for_query_forced                = var.cmk_for_query_forced
  immediate_data_purge_on_30_days_enabled = var.immediate_data_purge_on_30_days_enabled

  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []

    content {
      type         = var.identity_type
      identity_ids = var.identity_type == "UserAssigned" || var.identity_type == "SystemAssigned, UserAssigned" ? var.identity_ids : null
    }
  }

  tags = var.tags

  lifecycle {
    # Prevent accidental deletion
    prevent_destroy = false
  }
}

# Log Analytics Solutions
resource "azurerm_log_analytics_solution" "this" {
  for_each = var.solutions

  solution_name         = each.key
  resource_group_name   = var.resource_group_name
  location              = var.location
  workspace_resource_id = azurerm_log_analytics_workspace.this.id
  workspace_name        = azurerm_log_analytics_workspace.this.name

  plan {
    publisher = each.value.publisher
    product   = each.value.product
  }

  tags = var.tags

  depends_on = [
    azurerm_log_analytics_workspace.this
  ]
}
