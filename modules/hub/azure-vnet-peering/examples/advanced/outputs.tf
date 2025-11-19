output "hub_to_spoke1_peering_id" {
  description = "The ID of hub to spoke1 peering"
  value       = module.peering_hub_to_spoke1.id
}

output "spoke1_to_hub_peering_id" {
  description = "The ID of spoke1 to hub peering"
  value       = module.peering_spoke1_to_hub.id
}

output "hub_to_spoke2_peering_id" {
  description = "The ID of hub to spoke2 peering"
  value       = module.peering_hub_to_spoke2.id
}

output "spoke2_to_hub_peering_id" {
  description = "The ID of spoke2 to hub peering"
  value       = module.peering_spoke2_to_hub.id
}

output "all_peering_ids" {
  description = "All peering IDs created in this hub-spoke topology"
  value = {
    hub_to_spoke1  = module.peering_hub_to_spoke1.id
    spoke1_to_hub  = module.peering_spoke1_to_hub.id
    hub_to_spoke2  = module.peering_hub_to_spoke2.id
    spoke2_to_hub  = module.peering_spoke2_to_hub.id
  }
}

output "peering_configuration" {
  description = "Hub-spoke peering configuration details"
  value = {
    hub_to_spoke1 = {
      allow_forwarded_traffic = module.peering_hub_to_spoke1.allow_forwarded_traffic
      allow_gateway_transit   = module.peering_hub_to_spoke1.allow_gateway_transit
    }
    spoke1_to_hub = {
      allow_forwarded_traffic = module.peering_spoke1_to_hub.allow_forwarded_traffic
      use_remote_gateways     = module.peering_spoke1_to_hub.use_remote_gateways
    }
  }
}
