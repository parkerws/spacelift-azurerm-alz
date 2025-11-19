# Spacelift Environment Bootstrapper

Bootstrap your Spacelift environment for Azure landing zones.

## Purpose

This bootstrapper sets up:
1. **Spacelift Spaces**: Hierarchical organization structure
2. **Azure Service Principals**: Authentication for Spacelift stacks
3. **Spacelift Contexts**: Environment variables and configuration
4. **Initial Policies**: Base policy attachments

## Architecture

```
Root Space
├── landing-zones/          # Application landing zones
│   ├── corp/              # Corporate workloads
│   └── online/            # Internet-facing workloads
├── networking/            # Hub and spoke networks
│   ├── hub/
│   └── spokes/
├── shared-services/       # Platform shared services
│   ├── logging/
│   └── monitoring/
└── management/            # Governance and management
    ├── policies/
    └── rbac/
```

## Prerequisites

Before running the bootstrapper:

1. **Azure**:
   - Azure subscription with Owner role
   - Azure CLI authenticated: `az login`

2. **Spacelift**:
   - Spacelift account
   - API key with admin permissions
   - Set environment variable: `export SPACELIFT_API_KEY_ENDPOINT=https://your-account.app.spacelift.io`
   - Set environment variable: `export SPACELIFT_API_KEY_ID=your-key-id`
   - Set environment variable: `export SPACELIFT_API_KEY_SECRET=your-key-secret`

3. **Terraform/OpenTofu**:
   - Version >= 1.8.0

## Usage

### 1. Configure Variables

Create `terraform.tfvars`:

```hcl
# Spacelift Configuration
spacelift_account = "your-account"

# Azure Configuration
azure_subscription_id = "00000000-0000-0000-0000-000000000000"
azure_tenant_id       = "00000000-0000-0000-0000-000000000000"

# Naming
environment = "production"
location    = "eastus"
name_prefix = "alz"

# Tags
tags = {
  ManagedBy   = "Terraform"
  Environment = "Bootstrap"
  Purpose     = "Spacelift-Setup"
}
```

### 2. Initialize and Apply

```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### 3. Save Outputs

The bootstrapper outputs sensitive information:

```bash
# Save service principal credentials securely
terraform output -json service_principals > sp-credentials.json

# Store in Azure Key Vault (recommended)
az keyvault secret set \
  --vault-name "kv-spacelift-bootstrap" \
  --name "service-principals" \
  --file sp-credentials.json

# Delete local copy
shred -u sp-credentials.json
```

## Components

### Spaces (`spaces/`)

Creates hierarchical space structure:
- Inheritance of policies and contexts
- RBAC boundaries
- Organizational segmentation

### Service Principals (`service-principals/`)

Creates Azure service principals with least-privilege access:
- Hub SP: Manage connectivity resources
- Spoke SP: Limited to spoke resource groups
- Management SP: Azure Policy and RBAC
- Shared Services SP: Platform resources

### Contexts (`contexts/`)

Creates Spacelift contexts for:
- Azure credentials (per environment)
- Common environment variables
- Naming conventions
- Default tags

## Outputs

Key outputs from bootstrapper:

```hcl
# Space IDs for stack creation
space_ids = {
  landing_zones    = "space-123"
  networking       = "space-456"
  shared_services  = "space-789"
  management       = "space-012"
}

# Context IDs for stack attachment
context_ids = {
  azure_prod       = "context-abc"
  azure_dev        = "context-def"
  common_variables = "context-ghi"
}

# Service Principal IDs
service_principal_ids = {
  hub              = "sp-111"
  spoke            = "sp-222"
  management       = "sp-333"
  shared_services  = "sp-444"
}
```

## Post-Bootstrap Steps

After running the bootstrapper:

1. **Verify Spaces**: Check Spacelift UI for space hierarchy
2. **Test Authentication**: Create a test stack to verify Azure authentication
3. **Import Modules**: Register modules in Spacelift module registry
4. **Deploy Stack Factory**: Deploy administrative stack for hub-spoke creation

## Cleanup

To remove bootstrapped resources:

```bash
# WARNING: This will delete all Spacelift spaces and Azure service principals
terraform destroy
```

## Troubleshooting

### Service Principal Permission Issues

If stacks fail with permission errors:
1. Verify SP has correct role assignments
2. Check scope of role assignments (subscription vs resource group)
3. Wait for Azure AD replication (can take 5-10 minutes)

### Spacelift API Errors

If bootstrapper fails with API errors:
1. Verify API key has admin permissions
2. Check API endpoint URL
3. Verify account name is correct

## Security Considerations

1. **Service Principal Secrets**: Never commit credentials to Git
2. **Least Privilege**: Service principals have minimum required permissions
3. **Rotation**: Rotate SP credentials regularly (90 days recommended)
4. **Audit**: Enable Azure AD sign-in logs for SP activity
5. **Context Secrets**: Mark sensitive context variables as secret

## References

- [Spacelift Spaces](https://docs.spacelift.io/concepts/spaces)
- [Spacelift Contexts](https://docs.spacelift.io/concepts/configuration/context)
- [Azure Service Principals](https://learn.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals)
