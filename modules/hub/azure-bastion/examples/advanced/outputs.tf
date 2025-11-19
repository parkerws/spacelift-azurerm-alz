output "standard_bastion_id" {
  description = "The ID of the Standard Bastion"
  value       = module.bastion_standard.id
}

output "premium_bastion_id" {
  description = "The ID of the Premium Bastion"
  value       = module.bastion_premium.id
}

output "custom_ip_bastion_id" {
  description = "The ID of the Bastion with custom IP"
  value       = module.bastion_custom_ip.id
}

output "all_bastion_ids" {
  description = "All Bastion IDs created in this example"
  value = {
    standard  = module.bastion_standard.id
    premium   = module.bastion_premium.id
    custom_ip = module.bastion_custom_ip.id
  }
}

output "standard_bastion_details" {
  description = "Details of the Standard Bastion"
  value = {
    name         = module.bastion_standard.name
    dns_name     = module.bastion_standard.dns_name
    public_ip    = module.bastion_standard.public_ip_address
    sku          = module.bastion_standard.sku
    scale_units  = module.bastion_standard.scale_units
    zones        = module.bastion_standard.zones
    features     = module.bastion_standard.features
  }
}
