output "id" {
  description = "The ID of the Storage Account."
  value       = azurerm_storage_account.this.id
}

output "name" {
  description = "The name of the Storage Account."
  value       = azurerm_storage_account.this.name
}

output "primary_blob_endpoint" {
  description = "The endpoint URL for blob storage in the primary location."
  value       = azurerm_storage_account.this.primary_blob_endpoint
}

output "primary_blob_host" {
  description = "The hostname with port if applicable for blob storage in the primary location."
  value       = azurerm_storage_account.this.primary_blob_host
}

output "primary_queue_endpoint" {
  description = "The endpoint URL for queue storage in the primary location."
  value       = azurerm_storage_account.this.primary_queue_endpoint
}

output "primary_table_endpoint" {
  description = "The endpoint URL for table storage in the primary location."
  value       = azurerm_storage_account.this.primary_table_endpoint
}

output "primary_file_endpoint" {
  description = "The endpoint URL for file storage in the primary location."
  value       = azurerm_storage_account.this.primary_file_endpoint
}

output "primary_access_key" {
  description = "The primary access key for the storage account."
  value       = azurerm_storage_account.this.primary_access_key
  sensitive   = true
}

output "secondary_access_key" {
  description = "The secondary access key for the storage account."
  value       = azurerm_storage_account.this.secondary_access_key
  sensitive   = true
}

output "primary_connection_string" {
  description = "The connection string associated with the primary location."
  value       = azurerm_storage_account.this.primary_connection_string
  sensitive   = true
}

output "identity" {
  description = "The managed identity of the Storage Account."
  value       = var.identity != null ? azurerm_storage_account.this.identity : null
}

output "container_ids" {
  description = "Map of container names to their IDs."
  value       = { for k, v in azurerm_storage_container.this : k => v.id }
}

output "file_share_ids" {
  description = "Map of file share names to their IDs."
  value       = { for k, v in azurerm_storage_share.this : k => v.id }
}

output "queue_ids" {
  description = "Map of queue names to their IDs."
  value       = { for k, v in azurerm_storage_queue.this : k => v.id }
}

output "table_ids" {
  description = "Map of table names to their IDs."
  value       = { for k, v in azurerm_storage_table.this : k => v.id }
}

output "this" {
  description = "The full Storage Account resource object."
  value       = azurerm_storage_account.this
  sensitive   = true
}
