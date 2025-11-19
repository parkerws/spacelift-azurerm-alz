resource "azurerm_management_group" "this" {
  name                       = var.name
  display_name               = coalesce(var.display_name, var.name)
  parent_management_group_id = var.parent_management_group_id
  subscription_ids           = var.subscription_ids
}
