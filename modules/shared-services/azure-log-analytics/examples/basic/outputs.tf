output "workspace_id" {
  description = "The Workspace ID"
  value       = module.log_analytics.workspace_id
}

output "workspace_name" {
  description = "The Workspace name"
  value       = module.log_analytics.name
}
