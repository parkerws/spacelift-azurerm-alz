output "nsg_web_id" {
  description = "The ID of the web tier NSG"
  value       = module.nsg_web.id
}

output "nsg_app_id" {
  description = "The ID of the app tier NSG"
  value       = module.nsg_app.id
}

output "nsg_data_id" {
  description = "The ID of the data tier NSG"
  value       = module.nsg_data.id
}

output "asg_ids" {
  description = "Application Security Group IDs"
  value = {
    web  = azurerm_application_security_group.web.id
    app  = azurerm_application_security_group.app.id
    data = azurerm_application_security_group.data.id
  }
}

output "all_nsg_ids" {
  description = "All NSG IDs created in this example"
  value = {
    web        = module.nsg_web.id
    app        = module.nsg_app.id
    data       = module.nsg_data.id
    multi_port = module.nsg_multi_port.id
  }
}
