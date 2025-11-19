output "id" {
  description = "The ID of the Policy Assignment."
  value       = local.assignment.id
}

output "name" {
  description = "The name of the Policy Assignment."
  value       = local.assignment.name
}

output "display_name" {
  description = "The display name of the Policy Assignment."
  value       = local.assignment.display_name
}

output "identity" {
  description = "The identity configuration of the Policy Assignment."
  value       = try(local.assignment.identity, null)
}

output "scope" {
  description = "The scope of the Policy Assignment."
  value       = var.scope
}

output "this" {
  description = "The full Policy Assignment resource object."
  value       = local.assignment
}
