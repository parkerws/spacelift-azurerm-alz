output "aks_subnet_id" {
  description = "The ID of the AKS subnet"
  value       = module.subnet_aks.id
}

output "aks_subnet_service_endpoints" {
  description = "Service endpoints configured for AKS subnet"
  value       = module.subnet_aks.service_endpoints
}

output "data_subnet_id" {
  description = "The ID of the data subnet"
  value       = module.subnet_data.id
}

output "app_service_subnet_id" {
  description = "The ID of the App Service subnet"
  value       = module.subnet_app_service.id
}

output "netapp_subnet_id" {
  description = "The ID of the NetApp subnet"
  value       = module.subnet_netapp.id
}

output "all_subnet_ids" {
  description = "All subnet IDs created in this example"
  value = {
    aks         = module.subnet_aks.id
    data        = module.subnet_data.id
    app_service = module.subnet_app_service.id
    netapp      = module.subnet_netapp.id
  }
}
