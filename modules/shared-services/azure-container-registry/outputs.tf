output "id" {
  description = "The ID of the Container Registry."
  value       = azurerm_container_registry.this.id
}

output "name" {
  description = "The name of the Container Registry."
  value       = azurerm_container_registry.this.name
}

output "login_server" {
  description = "The URL that can be used to log into the container registry."
  value       = azurerm_container_registry.this.login_server
}

output "admin_username" {
  description = "The Username associated with the Container Registry Admin account - if the admin account is enabled."
  value       = var.admin_enabled ? azurerm_container_registry.this.admin_username : null
}

output "admin_password" {
  description = "The Password associated with the Container Registry Admin account - if the admin account is enabled."
  value       = var.admin_enabled ? azurerm_container_registry.this.admin_password : null
  sensitive   = true
}

output "identity" {
  description = "The managed identity of the Container Registry."
  value       = var.identity != null ? azurerm_container_registry.this.identity : null
}

output "webhook_ids" {
  description = "Map of webhook names to their IDs."
  value       = { for k, v in azurerm_container_registry_webhook.this : k => v.id }
}

output "this" {
  description = "The full Container Registry resource object."
  value       = azurerm_container_registry.this
  sensitive   = true
}
