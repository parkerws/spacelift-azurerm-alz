output "github_repository" {
  description = "GitHub repository details"
  value = {
    full_name = data.github_repository.this.full_name
    html_url  = data.github_repository.this.html_url
    ssh_url   = data.github_repository.this.ssh_clone_url
  }
}

output "environments" {
  description = "Created GitHub environments"
  value = {
    for k, v in github_repository_environment.environments :
    k => {
      id                  = v.id
      environment         = v.environment
      wait_timer          = v.wait_timer
      deployment_branch_policy = v.deployment_branch_policy
    }
  }
}

output "service_principal_details" {
  description = "Service principal information per environment"
  value = var.create_service_principals ? {
    for k, sp in azuread_service_principal.github_actions :
    k => {
      client_id        = sp.client_id
      object_id        = sp.object_id
      application_id   = sp.application_id
      display_name     = sp.display_name
      authentication   = var.use_oidc ? "OIDC" : "Client Secret"
    }
  } : {}
}

output "oidc_subjects" {
  description = "OIDC subject claims for federated identity"
  value = var.use_oidc && var.create_service_principals ? {
    for k, v in var.environments :
    k => {
      environment = "repo:${var.github_organization}/${var.github_repository}:environment:${k}"
      branch      = "repo:${var.github_organization}/${var.github_repository}:ref:refs/heads/${k == "production" ? "main" : k}"
    }
  } : {}
}

output "terraform_state_backend" {
  description = "Terraform state backend configuration"
  value = var.create_terraform_state_storage ? {
    resource_group_name  = azurerm_resource_group.tfstate[0].name
    storage_account_name = azurerm_storage_account.tfstate[0].name
    container_name       = azurerm_storage_container.tfstate[0].name

    backend_config = <<-EOT
      terraform {
        backend "azurerm" {
          resource_group_name  = "${azurerm_resource_group.tfstate[0].name}"
          storage_account_name = "${azurerm_storage_account.tfstate[0].name}"
          container_name       = "tfstate"
          key                  = "<stack-name>.tfstate"
        }
      }
    EOT
  } : null
}

output "github_secrets_configured" {
  description = "List of configured GitHub secrets"
  value = [
    "TERRAFORM_STATE_RESOURCE_GROUP",
    "TERRAFORM_STATE_STORAGE_ACCOUNT",
    "TERRAFORM_STATE_CONTAINER"
  ]
}

output "environment_secrets_configured" {
  description = "Secrets configured per environment"
  value = {
    for k, v in var.environments :
    k => var.use_oidc ? [
      "AZURE_CLIENT_ID",
      "AZURE_TENANT_ID",
      "AZURE_SUBSCRIPTION_ID"
    ] : [
      "AZURE_CLIENT_ID",
      "AZURE_TENANT_ID",
      "AZURE_SUBSCRIPTION_ID",
      "AZURE_CLIENT_SECRET"
    ]
  }
}

output "branch_protection_enabled" {
  description = "Branch protection configuration"
  value = var.enable_branch_protection ? {
    protected_branches  = var.protected_branches
    required_approvals  = var.required_approvals
    signed_commits      = true
  } : null
}

output "next_steps" {
  description = "Next steps to complete setup"
  value = <<-EOT
    GitHub Actions Bootstrap Complete!

    Next Steps:

    1. Review GitHub Environments:
       ${data.github_repository.this.html_url}/settings/environments

    2. Configure reviewers for production environment (if not already set)

    3. Test Azure authentication:
       gh workflow run test-azure-auth.yml --ref main

    4. Deploy your first hub:
       gh workflow run hub-deployment.yml --ref main -f environment=production

    5. Monitor deployments:
       ${data.github_repository.this.html_url}/actions

    Backend Configuration:
    ${var.create_terraform_state_storage ? "Add to your Terraform configurations:\n${join("\n", [for k, v in azurerm_storage_container.tfstate_environments : "  - ${k}: container=tfstate-${k}"])}" : "Configure your own Terraform backend"}

    Authentication Method: ${var.use_oidc ? "OIDC Federation (recommended)" : "Client Secret"}
  EOT
}

# Sensitive outputs
output "service_principal_secrets" {
  description = "Service principal client secrets (if using client secret auth)"
  value = !var.use_oidc && var.create_service_principals ? {
    for k, pwd in azuread_application_password.github_actions :
    k => {
      client_id     = azuread_application.github_actions[k].client_id
      client_secret = pwd.value
      tenant_id     = var.azure_tenant_id
    }
  } : {}
  sensitive = true
}

output "storage_access_key" {
  description = "Storage account access key for Terraform backend"
  value       = var.create_terraform_state_storage ? azurerm_storage_account.tfstate[0].primary_access_key : null
  sensitive   = true
}
