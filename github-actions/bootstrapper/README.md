# GitHub Actions Bootstrapper - Azure Landing Zone Factory

This bootstrapper configures GitHub Actions for deploying Azure Landing Zones.

## What It Creates

### 1. GitHub Environments

Creates environments with protection rules:
- **Production**: Requires manual approval, protected branches only
- **Staging**: Optional approval, all branches allowed
- **Development**: No approval, all branches allowed

### 2. Azure Service Principals

One service principal per environment with:
- OIDC federation (recommended) or client secrets
- Contributor access to subscription
- Storage Blob Data Contributor for state storage

### 3. Terraform State Storage

Azure Storage Account with:
- GRS replication for durability
- Blob versioning enabled
- Soft delete (30 days)
- Separate containers per environment

### 4. Branch Protection Rules

Enforces:
- Required pull request reviews (2 approvals for production)
- Status checks (validate, format, security scan)
- Signed commits
- Conversation resolution

### 5. GitHub Secrets & Variables

**Repository Secrets** (shared):
- `TERRAFORM_STATE_RESOURCE_GROUP`
- `TERRAFORM_STATE_STORAGE_ACCOUNT`
- `TERRAFORM_STATE_CONTAINER`

**Environment Secrets** (per environment):
- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`
- `AZURE_CLIENT_SECRET` (if not using OIDC)

## Prerequisites

1. **GitHub Personal Access Token** with repo and admin:org scopes
2. **Azure Permissions**: Ability to create service principals and role assignments
3. **Terraform**: Version >= 1.8.0

## Usage

### 1. Configure Variables

Create `terraform.tfvars`:

```hcl
# GitHub configuration
github_organization = "your-org"
github_repository   = "spacelift-azurerm-alz"

# Azure configuration
azure_tenant_id       = "00000000-0000-0000-0000-000000000000"
azure_subscription_id = "00000000-0000-0000-0000-000000000000"

# Authentication method
use_oidc = true  # Recommended over client secrets

# Service principal creation
create_service_principals = true

# Terraform state
create_terraform_state_storage = true
state_storage_location         = "eastus"

# Branch protection
enable_branch_protection = true
required_approvals       = 2

# Environment configuration
environments = {
  production = {
    wait_timer          = 0
    reviewers           = ["@your-org/platform-team"]
    deployment_branch_policy = "protected"
  }
  staging = {
    wait_timer          = 0
    deployment_branch_policy = "all"
  }
  development = {
    wait_timer          = 0
    deployment_branch_policy = "all"
  }
}
```

### 2. Set Environment Variables

```bash
# GitHub authentication
export GITHUB_TOKEN="ghp_your_personal_access_token"

# Azure authentication
export ARM_TENANT_ID="your-tenant-id"
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
```

### 3. Initialize and Apply

```bash
cd github-actions/bootstrapper
terraform init
terraform plan
terraform apply
```

### 4. Retrieve Outputs

```bash
# View all outputs
terraform output

# Get service principal details
terraform output service_principal_details

# Get OIDC subjects (if using OIDC)
terraform output oidc_subjects

# Get backend configuration
terraform output terraform_state_backend
```

## OIDC vs Client Secret Authentication

### OIDC Federation (Recommended)

**Advantages**:
- No long-lived secrets
- Automatic credential rotation
- Better security posture
- GitHub manages the trust relationship

**Configuration**:
```yaml
- name: Azure Login
  uses: azure/login@v1
  with:
    client-id: ${{ secrets.AZURE_CLIENT_ID }}
    tenant-id: ${{ secrets.AZURE_TENANT_ID }}
    subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

**Subject Claims**:
- Environment: `repo:org/repo:environment:production`
- Branch: `repo:org/repo:ref:refs/heads/main`

### Client Secret

**Use when**:
- OIDC not available
- Self-hosted runners without Azure connectivity

**Configuration**:
```yaml
- name: Azure Login
  uses: azure/login@v1
  with:
    creds: |
      {
        "clientId": "${{ secrets.AZURE_CLIENT_ID }}",
        "clientSecret": "${{ secrets.AZURE_CLIENT_SECRET }}",
        "tenantId": "${{ secrets.AZURE_TENANT_ID }}",
        "subscriptionId": "${{ secrets.AZURE_SUBSCRIPTION_ID }}"
      }
```

## Post-Bootstrap Configuration

### 1. Configure Environment Reviewers

If you have specific users or teams that should approve production deployments:

```hcl
environments = {
  production = {
    reviewers = [
      "user1",
      "user2",
      "@your-org/approvers-team"
    ]
  }
}
```

### 2. Add Additional Secrets

For integrations (cost estimation, Slack, etc.):

```bash
# Using GitHub CLI
gh secret set COST_ESTIMATION_API_KEY --repo your-org/repo

# Or in the GitHub UI
https://github.com/your-org/repo/settings/secrets/actions
```

### 3. Configure State Backend in Workflows

Use the output backend configuration:

```yaml
- name: Terraform Init
  run: |
    terraform init \
      -backend-config="resource_group_name=${{ secrets.TERRAFORM_STATE_RESOURCE_GROUP }}" \
      -backend-config="storage_account_name=${{ secrets.TERRAFORM_STATE_STORAGE_ACCOUNT }}" \
      -backend-config="container_name=tfstate-${{ inputs.environment }}" \
      -backend-config="key=${{ inputs.stack_name }}.tfstate"
```

### 4. Test Azure Authentication

Create `.github/workflows/test-auth.yml`:

```yaml
name: Test Azure Authentication

on:
  workflow_dispatch:

jobs:
  test-auth:
    runs-on: ubuntu-latest
    environment: development

    steps:
      - uses: azure/login@v1
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

      - name: Verify Azure Access
        run: |
          az account show
          az group list --output table
```

## Environment Configuration

### Production Environment

```hcl
production = {
  wait_timer          = 0  # No wait, but requires approval
  reviewers           = ["@platform-team"]
  deployment_branch_policy = "protected"  # Only from protected branches
}
```

**Protection Features**:
- Requires approval from platform team
- Only deployable from protected branches (main)
- Full audit trail

### Staging Environment

```hcl
staging = {
  wait_timer          = 0
  deployment_branch_policy = "all"  # Any branch can deploy
}
```

**Use Case**:
- Pre-production testing
- Integration testing
- Performance validation

### Development Environment

```hcl
development = {
  wait_timer          = 0
  deployment_branch_policy = "all"
}
```

**Use Case**:
- Feature development
- Quick iterations
- Developer testing

## Security Best Practices

1. **Use OIDC**: Eliminates long-lived credentials
2. **Rotate Secrets**: If using client secrets, rotate every 90 days
3. **Least Privilege**: Grant minimum required permissions
4. **Audit Logs**: Enable Azure AD sign-in logs
5. **Environment Secrets**: Use environment-scoped secrets, not repository-wide

## Troubleshooting

### OIDC Trust Relationship Fails

**Error**: "No valid federated identity credential found"

**Solution**:
1. Verify subject claim matches exactly
2. Check environment name is correct
3. Ensure application has federated credential configured

```bash
# List federated credentials
az ad app federated-credential list \
  --id <application-id>
```

### State Storage Access Denied

**Error**: "AuthorizationPermissionMismatch"

**Solution**:
1. Verify service principal has Storage Blob Data Contributor role
2. Wait for RBAC propagation (5-10 minutes)
3. Check storage account firewall rules

### Branch Protection Prevents Merge

**Error**: "Required status check 'terraform-validate' is expected"

**Solution**:
1. Ensure all required workflows are defined
2. Workflows must complete successfully
3. Add workflows to repository before enabling protection

## Maintenance

### Rotate Service Principal Secrets

```bash
# If using client secrets, rotate annually
terraform taint 'azuread_application_password.github_actions["production"]'
terraform apply
```

### Update GitHub Secrets

```bash
# Update after rotation
gh secret set AZURE_CLIENT_SECRET \
  --env production \
  --body "new-secret-value"
```

### Add New Environment

1. Add to `environments` variable
2. Run `terraform apply`
3. Configure reviewers in GitHub UI
4. Create environment-specific workflows

## Migration from Spacelift

### Key Differences

| Aspect | Spacelift | GitHub Actions |
|--------|-----------|----------------|
| Secrets | Contexts | Environment Secrets |
| Approvals | Policy-based | Environment Protection |
| Dependencies | Stack Dependencies | Workflow `needs` |
| State | Built-in | Azure Storage |

### Migration Steps

1. Run this bootstrapper
2. Move secrets from Spacelift contexts to GitHub secrets
3. Convert stack dependencies to workflow dependencies
4. Test in development environment first
5. Migrate production with approval gates

## Cost Considerations

### GitHub Actions

- **Free tier**: 2,000 minutes/month for private repos
- **Team plan**: 3,000 minutes/month
- **Enterprise**: 50,000 minutes/month
- **Additional**: $0.008/minute

### Azure Storage (State)

- **GRS Storage**: ~$0.05/GB/month
- **Operations**: Minimal cost for state operations
- **Bandwidth**: Included within Azure

### Service Principals

- **Free**: No cost for service principals
- **OIDC**: No additional cost

## Support

- **GitHub Actions**: https://docs.github.com/actions
- **Azure OIDC**: https://docs.microsoft.com/azure/active-directory/develop/workload-identity-federation
- **Terraform**: https://www.terraform.io/docs

## License

MIT License - see [LICENSE](../../LICENSE) for details.
