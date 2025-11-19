output "storage_account_id" {
  description = "The ID of the Storage Account"
  value       = module.storage.id
}

output "storage_account_name" {
  description = "The name of the Storage Account"
  value       = module.storage.name
}

output "primary_blob_endpoint" {
  description = "The primary blob endpoint"
  value       = module.storage.primary_blob_endpoint
}

output "container_ids" {
  description = "Map of container IDs"
  value       = module.storage.container_ids
}
