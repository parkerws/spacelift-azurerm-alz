terraform {
  required_version = ">= 1.8.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0, < 5.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {}

# Built-in policy: Audit VMs that do not use managed disks
data "azurerm_policy_definition" "audit_vm_managed_disks" {
  display_name = "Audit VMs that do not use managed disks"
}

# Built-in policy: Require a tag on resources
data "azurerm_policy_definition" "require_tag" {
  display_name = "Require a tag on resources"
}

# Built-in policy: Configure Azure Defender to be enabled on SQL servers
data "azurerm_policy_definition" "configure_defender_sql" {
  display_name = "Configure Azure Defender to be enabled on SQL servers"
}

# Policy assignment with system-assigned identity
module "policy_audit_vms" {
  source = "../.."

  name                 = "audit-vm-disks"
  display_name         = "Audit VMs without managed disks"
  description          = "Audits virtual machines that do not use managed disks for improved reliability"
  policy_definition_id = data.azurerm_policy_definition.audit_vm_managed_disks.id
  scope                = data.azurerm_subscription.current.id
  location             = "eastus"

  identity = {
    type = "SystemAssigned"
  }

  non_compliance_messages = [
    {
      content = "Virtual machines must use managed disks for improved reliability and security."
    }
  ]
}

# Policy assignment with parameters
module "policy_require_environment_tag" {
  source = "../.."

  name                 = "require-env-tag"
  display_name         = "Require Environment tag on resources"
  description          = "Enforces the presence of the Environment tag on all resources"
  policy_definition_id = data.azurerm_policy_definition.require_tag.id
  scope                = data.azurerm_subscription.current.id

  parameters = jsonencode({
    tagName = {
      value = "Environment"
    }
  })

  enforcement_mode = "Default"

  non_compliance_messages = [
    {
      content = "All resources must have an Environment tag indicating their deployment environment."
    }
  ]
}

# DeployIfNotExists policy with system-assigned identity
module "policy_defender_sql" {
  source = "../.."

  name                 = "deploy-defender-sql"
  display_name         = "Deploy Azure Defender for SQL servers"
  description          = "Automatically deploys Azure Defender on SQL servers"
  policy_definition_id = data.azurerm_policy_definition.configure_defender_sql.id
  scope                = data.azurerm_subscription.current.id
  location             = "eastus"

  identity = {
    type = "SystemAssigned"
  }

  enforcement_mode = "Default"

  non_compliance_messages = [
    {
      content = "SQL servers must have Azure Defender enabled for advanced threat protection."
    }
  ]
}

# Policy assignment with resource selectors (targeting specific resource types)
module "policy_with_selectors" {
  source = "../.."

  name                 = "tag-vms-only"
  display_name         = "Require tags on VMs only"
  description          = "Requires Environment tag specifically on virtual machines"
  policy_definition_id = data.azurerm_policy_definition.require_tag.id
  scope                = data.azurerm_subscription.current.id

  parameters = jsonencode({
    tagName = {
      value = "Environment"
    }
  })

  resource_selectors = [
    {
      name = "select-vms"
      selectors = [
        {
          kind = "resourceType"
          in   = ["Microsoft.Compute/virtualMachines"]
        }
      ]
    }
  ]

  non_compliance_messages = [
    {
      content = "Virtual machines must have an Environment tag."
    }
  ]
}

# Policy assignment in audit mode (DoNotEnforce)
module "policy_audit_only" {
  source = "../.."

  name                 = "audit-mode-test"
  display_name         = "Test policy in audit mode"
  description          = "Runs policy in audit mode without blocking deployments"
  policy_definition_id = data.azurerm_policy_definition.require_tag.id
  scope                = data.azurerm_subscription.current.id

  parameters = jsonencode({
    tagName = {
      value = "CostCenter"
    }
  })

  enforcement_mode = "DoNotEnforce"

  non_compliance_messages = [
    {
      content = "This is in audit mode: Resources should have a CostCenter tag for billing purposes."
    }
  ]
}
