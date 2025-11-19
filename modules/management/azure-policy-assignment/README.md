# Azure Policy Assignment Module

Terraform module for Azure Policy Assignments at management group, subscription, or resource group scope.

## Features

- Automatic scope detection (management group, subscription, resource group)
- Support for policy definitions and initiatives
- System-assigned and user-assigned managed identities
- Custom parameters and metadata
- Non-compliance messages
- Resource selectors for targeted enforcement
- Policy overrides for initiatives
- Enforcement mode configuration

## Usage

### Basic Configuration - Management Group Scope

```hcl
module "policy_assignment" {
  source = "../../modules/management/azure-policy-assignment"

  name                 = "require-tags"
  display_name         = "Require specific tags"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/xxxxx"
  scope                = "/providers/Microsoft.Management/managementGroups/mg-platform"
  enforcement_mode     = "Default"

  parameters = jsonencode({
    tagName = {
      value = "Environment"
    }
  })

  non_compliance_messages = [
    {
      content = "Resources must have an Environment tag."
    }
  ]
}
```

### Subscription Scope with Identity

```hcl
module "policy_audit_vms" {
  source = "../../modules/management/azure-policy-assignment"

  name                 = "audit-vm-managed-disks"
  display_name         = "Audit VMs without managed disks"
  description          = "Audits virtual machines that do not use managed disks"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/xxxxx"
  scope                = "/subscriptions/00000000-0000-0000-0000-000000000000"
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
```

### Initiative Assignment with Parameters

```hcl
module "policy_cis_benchmark" {
  source = "../../modules/management/azure-policy-assignment"

  name                 = "cis-benchmark"
  display_name         = "CIS Microsoft Azure Foundations Benchmark"
  description          = "Assigns the CIS Microsoft Azure Foundations Benchmark initiative"
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/xxxxx"
  scope                = "/providers/Microsoft.Management/managementGroups/mg-platform"
  location             = "eastus"

  identity = {
    type = "SystemAssigned"
  }

  parameters = jsonencode({
    effect = {
      value = "Audit"
    }
    minimumTlsVersion = {
      value = "1.2"
    }
  })

  non_compliance_messages = [
    {
      content                        = "Resources must comply with CIS Microsoft Azure Foundations Benchmark."
      policy_definition_reference_id = null
    }
  ]
}
```

### Resource Group Scope

```hcl
module "policy_rg" {
  source = "../../modules/management/azure-policy-assignment"

  name                 = "allowed-locations"
  display_name         = "Allowed locations for resources"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/xxxxx"
  scope                = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example"

  parameters = jsonencode({
    listOfAllowedLocations = {
      value = ["eastus", "westus2"]
    }
  })

  enforcement_mode = "Default"
}
```

### With Resource Selectors

```hcl
module "policy_with_selectors" {
  source = "../../modules/management/azure-policy-assignment"

  name                 = "require-tags-selective"
  display_name         = "Require tags on specific resources"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/xxxxx"
  scope                = "/subscriptions/00000000-0000-0000-0000-000000000000"

  resource_selectors = [
    {
      name = "select-vms-only"
      selectors = [
        {
          kind = "resourceType"
          in   = ["Microsoft.Compute/virtualMachines"]
        }
      ]
    }
  ]
}
```

## License

MIT License - see [LICENSE](../../../LICENSE) for details.
