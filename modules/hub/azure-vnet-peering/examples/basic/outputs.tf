output "peering_1_to_2_id" {
  description = "The ID of VNet 1 to VNet 2 peering"
  value       = module.peering_1_to_2.id
}

output "peering_2_to_1_id" {
  description = "The ID of VNet 2 to VNet 1 peering"
  value       = module.peering_2_to_1.id
}
