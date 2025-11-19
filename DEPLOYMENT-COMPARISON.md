# Deployment Platform Comparison: Spacelift vs GitHub Actions

Comprehensive comparison of Spacelift and GitHub Actions for Azure Landing Zone deployments.

## Executive Summary

| Criterion | Spacelift | GitHub Actions | Recommendation |
|-----------|-----------|----------------|----------------|
| **Ease of Setup** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | GitHub Actions (simpler bootstrap) |
| **State Management** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | Spacelift (built-in) |
| **Policy Enforcement** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | Spacelift (OPA/Rego native) |
| **Cost** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | GitHub Actions (included) |
| **Enterprise Features** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | Spacelift (purpose-built) |
| **Learning Curve** | ⭐⭐⭐ | ⭐⭐⭐⭐ | GitHub Actions (familiar) |

## Detailed Comparison

### 1. State Management

#### Spacelift
```
✅ Built-in state management
✅ Automatic state locking
✅ State versioning included
✅ No external dependencies
❌ Vendor lock-in for state
```

**Configuration**: None required (automatic)

#### GitHub Actions
```
✅ Flexible backend options
✅ Azure Storage integration
⚠️  Manual state backend setup
⚠️  Requires separate storage account
✅ Full control over state storage
```

**Configuration**:
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sttfstate"
    container_name       = "tfstate"
    key                  = "stack.tfstate"
  }
}
```

**Winner**: **Spacelift** (zero configuration)

### 2. Approval Workflows

#### Spacelift
- OPA/Rego policies
- Conditional approval based on:
  - Resource types
  - Cost estimates
  - Environment
  - Change scope
- Policy inheritance via spaces
- Automated policy evaluation

**Example**:
```rego
approve[msg] {
    input.run.state == "FINISHED"
    affects_production
    msg := "Production changes require approval"
}
```

#### GitHub Actions
- Environment protection rules
- Required reviewers
- Manual approval gates
- Branch protection rules
- CODEOWNERS integration

**Example**:
```yaml
environment:
  name: production
  reviewers: ["@platform-team"]
```

**Winner**: **Spacelift** (more granular, policy-based)

### 3. Dependencies & Orchestration

#### Spacelift
```yaml
# Stack dependencies (native)
depends_on:
  - hub-connectivity-prod

# Automatic triggering
# Policy-driven execution order
```

**Features**:
- Native stack dependencies
- Automatic dependency resolution
- Trigger policies for cascading deployments
- Dependency graph visualization

#### GitHub Actions
```yaml
# Workflow dependencies
needs: [check-hub-deployed]

# Manual orchestration
jobs:
  check-hub:
    runs-on: ubuntu-latest
  deploy-spoke:
    needs: check-hub
```

**Features**:
- Workflow-level dependencies
- Manual dependency checks
- Matrix deployments
- Reusable workflows

**Winner**: **Spacelift** (native infrastructure dependencies)

### 4. Cost

#### Spacelift Pricing
```
Starter: $175/month
  - 3 concurrent runs
  - 5 users
  - Basic features

Team: $500/month
  - 10 concurrent runs
  - Unlimited users
  - Advanced features

Enterprise: Custom
  - Unlimited runs
  - SSO, audit logs
  - Priority support
```

#### GitHub Actions Pricing
```
Free (Public repos):
  - Unlimited minutes

Free (Private repos):
  - 2,000 minutes/month
  - $0.008/minute after

Team: $4/user/month
  - 3,000 minutes/month
  - $0.008/minute after

Enterprise: $21/user/month
  - 50,000 minutes/month
  - $0.008/minute after
```

**Example Calculation** (100 runs/month, 5 min avg):
- Spacelift Team: $500/month
- GitHub Actions (Team): $4/user + (~500 min usage) = ~$20-40/month

**Winner**: **GitHub Actions** (lower cost for most use cases)

### 5. Policy Enforcement

#### Spacelift
**Native OPA/Rego Support**:
```rego
# Plan policy
deny[msg] {
    resource := input.terraform.resource_changes[_]
    resource.type == "azurerm_storage_account"
    resource.change.after.public_network_access_enabled == true
    msg := "Storage accounts must not have public access"
}
```

**Policy Types**:
- Plan policies (validation)
- Approval policies (gates)
- Push policies (triggers)
- Trigger policies (dependencies)

**Features**:
- Policy testing framework
- Policy inheritance
- Policy as code
- Real-time evaluation

#### GitHub Actions
**Custom Action-Based Policies**:
```yaml
- name: Security Scan
  uses: aquasecurity/trivy-action@master

- name: Cost Check
  run: |
    if [ $COST -gt 1000 ]; then
      echo "Cost exceeds threshold"
      exit 1
    fi
```

**Policy Mechanisms**:
- Branch protection rules
- Required status checks
- Custom actions
- Third-party integrations

**Winner**: **Spacelift** (native OPA, more powerful)

### 6. Multi-Environment Support

#### Spacelift
- **Spaces**: Hierarchical organization
- **Contexts**: Environment-specific variables
- **Inherited policies**: Policy propagation
- **Stack labels**: Flexible categorization

**Structure**:
```
Root
├── Platform (space)
│   ├── Production (context)
│   └── Development (context)
└── Landing Zones (space)
    ├── Corp (space)
    └── Online (space)
```

#### GitHub Actions
- **Environments**: GitHub environments
- **Secrets**: Environment-specific secrets
- **Branch rules**: Branch-based deployment
- **Matrix deployments**: Parallel environments

**Structure**:
```yaml
environment:
  name: production
  secrets:
    AZURE_CLIENT_ID: xxx
    AZURE_CLIENT_SECRET: xxx
```

**Winner**: **Tie** (different approaches, both effective)

### 7. Developer Experience

#### Spacelift
**Pros**:
- Web UI for stack management
- CLI for local development
- Terraform Cloud integration
- Run history and logs
- Drift detection

**Cons**:
- Separate platform to learn
- Another login to manage
- Specialized knowledge required

#### GitHub Actions
**Pros**:
- Integrated with GitHub
- Familiar YAML syntax
- Extensive action marketplace
- Easy debugging
- Native PR integration

**Cons**:
- More YAML configuration
- Less Terraform-specific features
- Manual state management

**Winner**: **GitHub Actions** (familiarity, integration)

### 8. Security & Compliance

#### Spacelift
```
✅ Built-in audit logs
✅ SSO/SAML integration
✅ SOC 2 Type II certified
✅ Role-based access control (RBAC)
✅ Encryption at rest and in transit
✅ Compliance frameworks supported
```

#### GitHub Actions
```
✅ GitHub Advanced Security
✅ Secret scanning
✅ Dependabot alerts
✅ OIDC authentication
✅ Audit logs (Enterprise)
✅ Compliance frameworks (Enterprise)
```

**Winner**: **Spacelift** (enterprise-grade out of box)

### 9. Drift Detection

#### Spacelift
- **Built-in drift detection**
- Scheduled drift checks
- Automatic notifications
- Drift reconciliation workflows

**Configuration**:
```
# Automatic scheduling
# No additional config required
```

#### GitHub Actions
- **Manual drift workflows**
- Scheduled via cron
- Custom notification logic

**Configuration**:
```yaml
on:
  schedule:
    - cron: '0 6 * * *'
```

**Winner**: **Spacelift** (native feature)

### 10. Integration & Extensibility

#### Spacelift
- Webhook integrations
- API for custom integrations
- Notification channels (Slack, Teams, etc.)
- Third-party modules
- Custom policies

#### GitHub Actions
- 15,000+ marketplace actions
- Custom actions (Docker, JavaScript, composite)
- Webhook events
- GitHub Apps
- REST/GraphQL API

**Winner**: **GitHub Actions** (larger ecosystem)

## Use Case Recommendations

### Choose Spacelift If:

1. ✅ **Infrastructure as a Service**
   - You want a purpose-built IaC platform
   - Native Terraform features are critical
   - State management is a concern

2. ✅ **Complex Governance Requirements**
   - Advanced policy enforcement needed
   - OPA/Rego policies required
   - Compliance frameworks are strict

3. ✅ **Large Scale Deployments**
   - Managing 50+ stacks
   - Complex dependency graphs
   - Multiple teams with different permissions

4. ✅ **Enterprise Features**
   - SSO/SAML required
   - Audit logging is critical
   - Dedicated support needed

### Choose GitHub Actions If:

1. ✅ **Existing GitHub Workflow**
   - Already using GitHub for source control
   - Want unified CI/CD platform
   - Team familiar with GitHub Actions

2. ✅ **Cost Optimization**
   - Limited budget
   - Included in existing GitHub license
   - Moderate deployment volume

3. ✅ **Flexibility**
   - Want full control over workflows
   - Need custom integrations
   - Prefer open ecosystems

4. ✅ **Quick Start**
   - Need to get started quickly
   - Minimal learning curve
   - Small to medium deployments

## Migration Path

### From Spacelift to GitHub Actions

1. **Export Configurations**
   ```bash
   # Export stack configurations
   spacelift stack export > stacks.json
   ```

2. **Create GitHub Workflows**
   ```bash
   # Use provided templates
   cp github-actions/workflows/hub/* .github/workflows/
   ```

3. **Setup State Backend**
   ```bash
   # Run bootstrapper
   cd github-actions/bootstrapper
   terraform apply
   ```

4. **Migrate Policies**
   - Convert OPA policies to workflow steps
   - Implement as custom actions

5. **Test in Development**
   - Deploy to development environment
   - Validate workflows
   - Adjust as needed

### From GitHub Actions to Spacelift

1. **Setup Spacelift**
   ```bash
   # Run bootstrapper
   cd bootstrapper
   terraform apply
   ```

2. **Create Stacks**
   ```bash
   # Use stack factory
   cd stack-factory/admin
   terraform apply
   ```

3. **Migrate Policies**
   - Convert workflow checks to Rego
   - Implement in policy library

4. **Import State**
   ```bash
   # Import existing state
   spacelift stack import
   ```

## Hybrid Approach

You can use both platforms:

### GitHub Actions For:
- Code validation (fmt, validate)
- Security scanning
- Pull request automation
- Testing

### Spacelift For:
- Production deployments
- State management
- Policy enforcement
- Drift detection

**Example Workflow**:
```
Developer PR
    ↓
GitHub Actions (validate, test, scan)
    ↓
Approve PR
    ↓
Merge to main
    ↓
Spacelift (plan, approve, apply)
    ↓
Production Deployment
```

## Conclusion

**For Most Organizations**: Start with **GitHub Actions**
- Lower cost
- Faster setup
- Familiar tooling
- Good enough for 80% of use cases

**For Large Enterprises**: Consider **Spacelift**
- Purpose-built for IaC
- Advanced governance
- Better for scale
- Enterprise features

**Best Practice**: Start with GitHub Actions, evaluate Spacelift as you scale.

## Decision Matrix

Answer these questions:

1. **Budget**: < $500/month → **GitHub Actions**
2. **Team Size**: < 10 people → **GitHub Actions**
3. **Stack Count**: > 50 stacks → **Spacelift**
4. **Compliance**: SOC 2 required → **Spacelift**
5. **Existing Tools**: Using GitHub → **GitHub Actions**
6. **Policy Complexity**: Complex OPA policies → **Spacelift**
7. **State Management**: Want fully managed → **Spacelift**
8. **Integration**: Need many integrations → **GitHub Actions**

## References

- [Spacelift Documentation](https://docs.spacelift.io)
- [GitHub Actions Documentation](https://docs.github.com/actions)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices)
- [Azure Landing Zones](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/)
