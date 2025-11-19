# Spacelift Policies

This directory contains OPA (Open Policy Agent) policies for governing Spacelift stacks.

## Policy Types

### Plan Policies (`plan/`)
Evaluate Terraform plans before apply:
- **cost-control.rego**: Prevent expensive resource provisioning
- **compliance.rego**: Enforce organizational compliance (tagging, naming, regions)
- **security.rego**: Security validation (public access, encryption, etc.)
- **resource-limits.rego**: Limit resource counts and sizes

### Approval Policies (`approval/`)
Control deployment approvals:
- **production-approval.rego**: Require manual approval for production stacks
- **destructive-changes.rego**: Require approval for resource deletion
- **high-cost-changes.rego**: Require approval for expensive changes

### Push Policies (`push/`)
Control which Git events trigger runs:
- **auto-deploy-dev.rego**: Auto-deploy on merge to dev branches
- **auto-deploy-prod.rego**: Auto-deploy on tag creation
- **ignore-paths.rego**: Ignore runs for documentation changes

### Trigger Policies (`trigger/`)
Manage stack dependencies:
- **hub-spoke-ordering.rego**: Ensure hub deploys before spokes
- **shared-services-first.rego**: Deploy shared services before workloads
- **network-dependencies.rego**: Enforce network provisioning order

## Policy Structure

Each policy includes:
```
policy-name/
├── policy.rego           # OPA policy code
├── policy_test.rego      # Test cases
├── examples/
│   ├── allow/           # Plans that should pass
│   └── deny/            # Plans that should fail
└── README.md            # Policy documentation
```

## Usage

### Attach to Spaces

Policies can be attached to Spacelift spaces for inheritance:

```hcl
resource "spacelift_policy" "compliance" {
  name = "Compliance Policy"
  body = file("${path.module}/policies/plan/compliance.rego")
  type = "PLAN"
}

resource "spacelift_policy_attachment" "landing_zones_compliance" {
  policy_id = spacelift_policy.compliance.id
  space_id  = spacelift_space.landing_zones.id
}
```

### Attach to Stacks

Or attach to individual stacks:

```hcl
resource "spacelift_policy_attachment" "prod_approval" {
  policy_id = spacelift_policy.production_approval.id
  stack_id  = spacelift_stack.hub_production.id
}
```

## Testing Policies

Test policies locally with OPA:

```bash
# Install OPA
brew install opa

# Test a policy
cd policies/plan/cost-control
opa test . -v
```

## Writing Policies

Example plan policy structure:

```rego
package spacelift

import future.keywords.contains
import future.keywords.if

# Deny resources without required tags
deny contains msg if {
    some resource in input.terraform.resource_changes
    resource.change.actions != ["delete"]

    required_tags := ["Environment", "Owner", "CostCenter"]
    missing_tags := [tag | tag := required_tags[_]; not resource.change.after.tags[tag]]

    count(missing_tags) > 0

    msg := sprintf(
        "Resource %s is missing required tags: %s",
        [resource.address, concat(", ", missing_tags)]
    )
}

# Sample decision
sample := true
```

## Policy Best Practices

1. **Informative Messages**: Include resource addresses and clear explanations
2. **Test Coverage**: Include both positive and negative test cases
3. **Performance**: Keep policies efficient for large plans
4. **Flexibility**: Use data sources for configuration rather than hardcoding
5. **Documentation**: Explain the purpose and examples in README

## References

- [Spacelift Policy Documentation](https://docs.spacelift.io/concepts/policy)
- [OPA Documentation](https://www.openpolicyagent.org/docs/latest/)
- [Rego Language Guide](https://www.openpolicyagent.org/docs/latest/policy-language/)
