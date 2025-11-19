output "id" {
  description = "The ID of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.this.id
}

output "name" {
  description = "The name of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.this.name
}

output "resource_group_name" {
  description = "The name of the resource group in which the Log Analytics Workspace exists."
  value       = azurerm_log_analytics_workspace.this.resource_group_name
}

output "location" {
  description = "The location/region where the Log Analytics Workspace exists."
  value       = azurerm_log_analytics_workspace.this.location
}

output "workspace_id" {
  description = "The Workspace (or Customer) ID for the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.this.workspace_id
}

output "primary_shared_key" {
  description = "The primary shared key for the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.this.primary_shared_key
  sensitive   = true
}

output "secondary_shared_key" {
  description = "The secondary shared key for the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.this.secondary_shared_key
  sensitive   = true
}

output "sku" {
  description = "The SKU of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.this.sku
}

output "retention_in_days" {
  description = "The data retention in days."
  value       = azurerm_log_analytics_workspace.this.retention_in_days
}

output "daily_quota_gb" {
  description = "The daily quota for ingestion in GB."
  value       = azurerm_log_analytics_workspace.this.daily_quota_gb
}

output "identity" {
  description = "The identity of the Log Analytics Workspace."
  value       = try(azurerm_log_analytics_workspace.this.identity[0], null)
}

output "solution_ids" {
  description = "Map of solution names to their IDs."
  value       = { for k, v in azurerm_log_analytics_solution.this : k => v.id }
}

output "this" {
  description = "The full Log Analytics Workspace resource object. Use this output for accessing attributes not explicitly exposed."
  value       = azurerm_log_analytics_workspace.this
  sensitive   = true
}
