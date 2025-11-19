output "management_group_id" {
  description = "The ID of the Management Group"
  value       = module.management_group.id
}

output "management_group_name" {
  description = "The name of the Management Group"
  value       = module.management_group.name
}

output "display_name" {
  description = "The display name of the Management Group"
  value       = module.management_group.display_name
}
