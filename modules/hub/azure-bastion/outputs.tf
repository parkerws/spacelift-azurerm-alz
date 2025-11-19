output "id" {
  description = "The ID of the Bastion Host."
  value       = azurerm_bastion_host.this.id
}

output "name" {
  description = "The name of the Bastion Host."
  value       = azurerm_bastion_host.this.name
}

output "resource_group_name" {
  description = "The name of the resource group in which the Bastion Host exists."
  value       = azurerm_bastion_host.this.resource_group_name
}

output "location" {
  description = "The location/region where the Bastion Host exists."
  value       = azurerm_bastion_host.this.location
}

output "sku" {
  description = "The SKU of the Bastion Host."
  value       = azurerm_bastion_host.this.sku
}

output "dns_name" {
  description = "The FQDN for the Bastion Host."
  value       = azurerm_bastion_host.this.dns_name
}

output "public_ip_address" {
  description = "The public IP address of the Bastion Host."
  value       = var.create_public_ip ? azurerm_public_ip.bastion[0].ip_address : null
}

output "public_ip_id" {
  description = "The ID of the public IP address associated with the Bastion Host."
  value       = local.public_ip_id
}

output "scale_units" {
  description = "The number of scale units provisioned for the Bastion Host."
  value       = azurerm_bastion_host.this.scale_units
}

output "zones" {
  description = "The availability zones of the Bastion Host."
  value       = azurerm_bastion_host.this.zones
}

output "features" {
  description = "Enabled features on the Bastion Host."
  value = {
    copy_paste       = azurerm_bastion_host.this.copy_paste_enabled
    file_copy        = azurerm_bastion_host.this.file_copy_enabled
    ip_connect       = azurerm_bastion_host.this.ip_connect_enabled
    shareable_link   = azurerm_bastion_host.this.shareable_link_enabled
    tunneling        = azurerm_bastion_host.this.tunneling_enabled
    kerberos         = azurerm_bastion_host.this.kerberos_enabled
  }
}

output "this" {
  description = "The full Bastion Host resource object. Use this output for accessing attributes not explicitly exposed."
  value       = azurerm_bastion_host.this
}
