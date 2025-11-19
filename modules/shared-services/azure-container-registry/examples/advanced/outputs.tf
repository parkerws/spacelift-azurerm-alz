output "acr_id" {
  description = "The ID of the Container Registry"
  value       = module.acr_premium.id
}

output "acr_name" {
  description = "The name of the Container Registry"
  value       = module.acr_premium.name
}

output "login_server" {
  description = "The login server URL"
  value       = module.acr_premium.login_server
}

output "identity" {
  description = "The managed identity configuration"
  value       = module.acr_premium.identity
}

output "webhook_ids" {
  description = "Map of webhook IDs"
  value       = module.acr_premium.webhook_ids
}
