output "spoke_route_table_id" {
  description = "The ID of the spoke route table"
  value       = module.route_table_spoke.id
}

output "gateway_subnet_route_table_id" {
  description = "The ID of the gateway subnet route table"
  value       = module.route_table_gateway_subnet.id
}

output "private_endpoints_route_table_id" {
  description = "The ID of the private endpoints route table"
  value       = module.route_table_private_endpoints.id
}

output "forced_tunnel_route_table_id" {
  description = "The ID of the forced tunneling route table"
  value       = module.route_table_forced_tunnel.id
}

output "multi_region_route_table_id" {
  description = "The ID of the multi-region route table"
  value       = module.route_table_multi_region.id
}

output "all_route_table_ids" {
  description = "All route table IDs created in this example"
  value = {
    spoke             = module.route_table_spoke.id
    gateway_subnet    = module.route_table_gateway_subnet.id
    private_endpoints = module.route_table_private_endpoints.id
    forced_tunnel     = module.route_table_forced_tunnel.id
    multi_region      = module.route_table_multi_region.id
  }
}

output "spoke_routes" {
  description = "Routes configured in the spoke route table"
  value       = module.route_table_spoke.routes
}
