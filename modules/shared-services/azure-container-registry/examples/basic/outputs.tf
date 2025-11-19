output "acr_id" {
  description = "The ID of the Container Registry"
  value       = module.acr.id
}

output "acr_name" {
  description = "The name of the Container Registry"
  value       = module.acr.name
}

output "login_server" {
  description = "The login server URL"
  value       = module.acr.login_server
}
