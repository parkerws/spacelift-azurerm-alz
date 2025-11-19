output "storage_account_id" {
  description = "The ID of the Storage Account"
  value       = module.storage_advanced.id
}

output "storage_account_name" {
  description = "The name of the Storage Account"
  value       = module.storage_advanced.name
}

output "primary_blob_endpoint" {
  description = "The primary blob endpoint"
  value       = module.storage_advanced.primary_blob_endpoint
}

output "primary_blob_host" {
  description = "The primary blob host"
  value       = module.storage_advanced.primary_blob_host
}

output "identity" {
  description = "The managed identity configuration"
  value       = module.storage_advanced.identity
}

output "container_ids" {
  description = "Map of container IDs"
  value       = module.storage_advanced.container_ids
}

output "file_share_ids" {
  description = "Map of file share IDs"
  value       = module.storage_advanced.file_share_ids
}

output "queue_ids" {
  description = "Map of queue IDs"
  value       = module.storage_advanced.queue_ids
}

output "table_ids" {
  description = "Map of table IDs"
  value       = module.storage_advanced.table_ids
}
