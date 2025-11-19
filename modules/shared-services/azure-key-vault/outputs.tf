output "id" {
  description = "The ID of the Key Vault."
  value       = azurerm_key_vault.this.id
}

output "name" {
  description = "The name of the Key Vault."
  value       = azurerm_key_vault.this.name
}

output "vault_uri" {
  description = "The URI of the Key Vault."
  value       = azurerm_key_vault.this.vault_uri
}

output "tenant_id" {
  description = "The tenant ID."
  value       = azurerm_key_vault.this.tenant_id
}

output "this" {
  description = "The full Key Vault resource object."
  value       = azurerm_key_vault.this
}
