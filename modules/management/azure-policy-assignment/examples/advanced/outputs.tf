output "audit_vms_id" {
  description = "Policy assignment ID for VM audit"
  value       = module.policy_audit_vms.id
}

output "audit_vms_identity" {
  description = "Managed identity for VM audit policy"
  value       = module.policy_audit_vms.identity
}

output "require_tag_id" {
  description = "Policy assignment ID for required tag"
  value       = module.policy_require_environment_tag.id
}

output "defender_sql_id" {
  description = "Policy assignment ID for Defender SQL"
  value       = module.policy_defender_sql.id
}

output "defender_sql_identity" {
  description = "Managed identity for Defender SQL policy"
  value       = module.policy_defender_sql.identity
}

output "selector_policy_id" {
  description = "Policy assignment ID with resource selectors"
  value       = module.policy_with_selectors.id
}

output "audit_mode_id" {
  description = "Policy assignment ID in audit mode"
  value       = module.policy_audit_only.id
}
