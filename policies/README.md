# Spacelift Policy Library

A collection of Spacelift policies for Azure Landing Zone governance and compliance.

## Policy Types

Spacelift supports four types of policies:

1. **Plan Policies**: Evaluate Terraform plans before execution
2. **Approval Policies**: Determine when manual approval is required
3. **Push Policies**: Control what triggers runs based on Git commits
4. **Trigger Policies**: Define dependencies between stacks

## Available Policies

### Plan Policies

Plan policies are evaluated after `terraform plan` completes and can:
- Approve or deny the plan
- Add warnings to the run
- Provide cost estimates and security recommendations

#### `plan/cost-estimation.rego`

**Purpose**: Cost control and visibility

**What it does**:
- Warns if estimated monthly cost exceeds $1,000
- Denies if estimated monthly cost exceeds $5,000
- Warns on cost increases > 50%

**Usage**:
```hcl
resource "spacelift_policy" "cost_estimation" {
  name = "cost-estimation"
  body = file("${path.module}/plan/cost-estimation.rego")
  type = "PLAN"
}

resource "spacelift_policy_attachment" "cost" {
  policy_id = spacelift_policy.cost_estimation.id
  stack_id  = spacelift_stack.production.id
}
```

#### `plan/require-tags.rego`

**Purpose**: Enforce Azure resource tagging standards

**What it does**:
- Requires tags: Environment, ManagedBy, CostCenter, Owner
- Validates Environment tag values (Development, Staging, Production, Sandbox)
- Warns on empty tag values

**Required Tags**:
- `Environment`: Deployment environment
- `ManagedBy`: Tool managing the resource (Terraform/Spacelift)
- `CostCenter`: Cost allocation identifier
- `Owner`: Resource owner/team

#### `plan/prevent-public-exposure.rego`

**Purpose**: Security hardening - prevent public exposure of PaaS services

**What it does**:
- Denies storage accounts with public network access
- Denies public blob containers
- Denies public Key Vaults in Production
- Denies public ACR in Production
- Denies public SQL servers
- Warns on NSG rules allowing SSH/RDP from internet

### Approval Policies

Approval policies determine when a run requires manual approval.

#### `approval/require-approval-production.rego`

**Purpose**: Protect production environments with mandatory approvals

**What it does**:
- Requires approval for all Production environment changes
- Requires approval for any deletion operations
- Requires approval for resource replacements
- Requires approval for costs > $2,000/month
- Requires approval for changes in production space

### Push Policies

Push policies control what Git changes trigger Spacelift runs.

#### `push/conventional-commits.rego`

**Purpose**: Enforce conventional commit message standards

**What it does**:
- Enforces conventional commits format: `type(scope): description`
- Valid types: feat, fix, docs, style, refactor, perf, test, chore, ci, build, revert
- Warns on short messages (< 20 chars)
- Warns on long first lines (> 100 chars)
- Allows merge commits and dependency updates

**Examples**:
```
✅ feat(networking): add hub VNet peering
✅ fix(storage): resolve public access configuration
✅ docs: update README with deployment steps
✅ refactor(modules): extract common variables
❌ updated files
❌ WIP
❌ quick fix
```

### Trigger Policies

Trigger policies define dependencies between stacks.

#### `trigger/hub-spoke-dependencies.rego`

**Purpose**: Enforce deployment order for hub-spoke architecture

**What it does**:
- Ensures hub infrastructure deploys first
- Triggers platform stacks after hub completion
- Triggers spoke stacks after hub completion
- Prevents spoke deployment if hub isn't healthy

**Stack Identification**:
- Hub stacks: Contain "hub" or "connectivity" in name/labels
- Spoke stacks: Contain "spoke" in name/labels
- Platform stacks: Contain "platform", "management", or "shared-services"

## Policy Attachment Strategy

### Space-Level Attachment

Attach policies to spaces for broad coverage:

```hcl
# Attach to all production stacks
resource "spacelift_policy_attachment" "production_approval" {
  policy_id = spacelift_policy.require_approval.id
  space_id  = spacelift_space.production.id
}
```

### Stack-Level Attachment

Attach policies to specific stacks:

```hcl
# Attach to specific stack
resource "spacelift_policy_attachment" "hub_cost" {
  policy_id = spacelift_policy.cost_estimation.id
  stack_id  = spacelift_stack.hub_networking.id
}
```

### Recommended Attachments

| Policy | Scope | Spaces/Stacks |
|--------|-------|---------------|
| `cost-estimation` | All | Root space |
| `require-tags` | All | Root space |
| `prevent-public-exposure` | All | Root space |
| `require-approval-production` | Production | Platform, Landing Zones (production) |
| `conventional-commits` | All | Root space |
| `hub-spoke-dependencies` | Networking | Connectivity space |

## Testing Policies Locally

Use Spacelift's policy testing tools:

```bash
# Install Spacelift CLI
brew install spacelift-io/spacelift/spacelift

# Test a policy
spacelift policy test plan/cost-estimation.rego \
  --input test-data/plan.json

# Validate policy syntax
spacelift policy validate plan/cost-estimation.rego
```

## Writing Custom Policies

### Plan Policy Template

```rego
package spacelift

# Deny if condition met
deny[msg] {
    resource := input.terraform.resource_changes[_]
    # Your condition here
    msg := "Your error message"
}

# Warn if condition met
warn[msg] {
    resource := input.terraform.resource_changes[_]
    # Your condition here
    msg := "Your warning message"
}

# Required for all policies
sample { true }
```

### Approval Policy Template

```rego
package spacelift

# Require approval if condition met
approve[msg] {
    input.run.type == "TRACKED"
    # Your condition here
    msg := "Reason for requiring approval"
}

sample { true }
```

### Available Input Data

**Plan Policies**:
- `input.terraform.resource_changes` - All resource changes
- `input.third_party_metadata` - Custom metadata (cost, etc.)
- `input.run` - Run information

**Approval Policies**:
- `input.run` - Run details (type, state, labels)
- `input.terraform.resource_changes` - Resource changes

**Push Policies**:
- `input.push` - Push information
- `input.push.head.message` - Commit message

**Trigger Policies**:
- `input.stack` - Stack information
- `input.run` - Run state

## Best Practices

1. **Start Permissive**: Begin with warnings, transition to denials after validation
2. **Clear Messages**: Provide actionable error messages
3. **Test Thoroughly**: Test policies with sample plans before deploying
4. **Version Control**: Track policy changes in Git
5. **Document Exceptions**: Document why certain policies don't apply to specific stacks
6. **Monitor Impact**: Review policy evaluations regularly

## Policy Evaluation Order

Spacelift evaluates policies in this order:

1. **Push Policy** - Should this commit trigger a run?
2. **Plan Policy** - Is this plan compliant?
3. **Approval Policy** - Does this run need approval?
4. **Trigger Policy** - What other stacks should run?

## Debugging Policies

View policy evaluation results in:
- Spacelift UI: Stack → Run → Policy Results
- Spacelift API: `GET /stacks/:id/runs/:id/policies`

Common issues:
- **Policy always denies**: Check sample rule exists
- **Policy never evaluates**: Verify attachment
- **Unexpected results**: Add debug print statements

## Migration from Other Tools

### From OPA/Conftest

Spacelift uses OPA (Open Policy Agent) with Rego, so existing Conftest policies can often be migrated with minimal changes:

1. Change package to `spacelift`
2. Update input structure to match Spacelift
3. Add `sample { true }` rule

### From Sentinel

Sentinel policies need rewriting in Rego:
- Study the [Rego documentation](https://www.openpolicyagent.org/docs/latest/policy-language/)
- Use Spacelift's input structure
- Test incrementally

## Examples

See the `/examples` directory for:
- Sample Terraform plans
- Policy test data
- Integration examples

## Contributing

To add new policies:

1. Create policy file in appropriate directory
2. Add documentation to this README
3. Include test cases
4. Submit pull request

## License

MIT License - see [LICENSE](../LICENSE) for details.
