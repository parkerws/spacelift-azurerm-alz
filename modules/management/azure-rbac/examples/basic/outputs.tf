output "role_assignment_id" {
  description = "The ID of the Role Assignment"
  value       = module.rbac_reader.id
}

output "role_assignment_name" {
  description = "The name of the Role Assignment"
  value       = module.rbac_reader.name
}

output "role_definition_name" {
  description = "The role definition name"
  value       = module.rbac_reader.role_definition_name
}
