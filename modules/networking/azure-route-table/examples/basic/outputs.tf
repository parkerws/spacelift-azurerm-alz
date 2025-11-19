output "route_table_id" {
  description = "The ID of the route table"
  value       = module.route_table.id
}

output "route_table_name" {
  description = "The name of the route table"
  value       = module.route_table.name
}

output "routes" {
  description = "The routes in the route table"
  value       = module.route_table.routes
}
