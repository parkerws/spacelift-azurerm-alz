# Azure Landing Zone Factory CLI

Command-line tool for managing Azure Landing Zone stacks with Spacelift.

## Installation

```bash
# Install from source
cd cli
pip install -e .

# Or install directly
pip install -r requirements.txt
python setup.py install
```

## Requirements

- Python >= 3.9
- Azure CLI (for authentication)
- Spacelift CLI (optional, for advanced features)

## Quick Start

```bash
# Initialize a new spoke landing zone
azlz init spoke \
  --name spoke-corp-prod-003 \
  --environment production \
  --location eastus \
  --hub hub-connectivity-prod

# Validate configuration
azlz validate stacks.yaml

# Generate Terraform configuration
azlz generate spoke-corp-prod-003

# Create Spacelift stack
azlz deploy spoke-corp-prod-003
```

## Commands

### `azlz init`

Initialize a new landing zone configuration.

```bash
# Initialize a spoke
azlz init spoke \
  --name spoke-corp-prod-003 \
  --environment production \
  --location eastus \
  --address-space 10.3.0.0/16 \
  --hub hub-connectivity-prod

# Initialize a hub
azlz init hub \
  --name hub-connectivity-secondary \
  --environment production \
  --location westus2 \
  --address-space 10.200.0.0/16

# With interactive prompts
azlz init spoke --interactive
```

**Options**:
- `--name`: Stack name (required)
- `--environment`: Environment (production, development, staging)
- `--location`: Azure region
- `--address-space`: VNet CIDR
- `--hub`: Hub stack name (spokes only)
- `--interactive`: Use interactive prompts

### `azlz validate`

Validate stack configuration.

```bash
# Validate stacks.yaml
azlz validate stacks.yaml

# Validate specific stack
azlz validate --stack spoke-corp-prod-003

# Validate with detailed output
azlz validate --verbose
```

**Checks**:
- YAML syntax
- Required fields
- CIDR overlap detection
- Hub dependencies
- Naming conventions
- Tag requirements

### `azlz generate`

Generate Terraform configuration from templates.

```bash
# Generate for specific stack
azlz generate spoke-corp-prod-003

# Generate all stacks
azlz generate --all

# Output to specific directory
azlz generate spoke-corp-prod-003 --output ./generated
```

### `azlz deploy`

Deploy stack to Spacelift.

```bash
# Deploy specific stack
azlz deploy spoke-corp-prod-003

# Deploy with auto-approve
azlz deploy spoke-corp-prod-003 --auto-approve

# Dry run (plan only)
azlz deploy spoke-corp-prod-003 --dry-run
```

### `azlz list`

List configured stacks.

```bash
# List all stacks
azlz list

# List hubs only
azlz list --type hub

# List spokes for specific hub
azlz list --hub hub-connectivity-prod

# Output as JSON
azlz list --format json
```

### `azlz destroy`

Remove stack from Spacelift.

```bash
# Destroy specific stack
azlz destroy spoke-corp-prod-003

# With confirmation
azlz destroy spoke-corp-prod-003 --confirm

# Force destroy (skip dependencies)
azlz destroy spoke-corp-prod-003 --force
```

### `azlz config`

Manage CLI configuration.

```bash
# Show current configuration
azlz config show

# Set configuration value
azlz config set spacelift.endpoint https://your-account.app.spacelift.io
azlz config set azure.subscription_id 00000000-0000-0000-0000-000000000000

# Initialize configuration
azlz config init
```

## Configuration

### CLI Configuration File

Create `~/.azlz/config.yaml`:

```yaml
spacelift:
  endpoint: https://your-account.app.spacelift.io
  api_key_id: ${SPACELIFT_API_KEY_ID}
  api_key_secret: ${SPACELIFT_API_KEY_SECRET}

azure:
  tenant_id: 00000000-0000-0000-0000-000000000000
  subscription_id: 00000000-0000-0000-0000-000000000000

defaults:
  environment: development
  location: eastus
  terraform_version: "1.8.0"

templates:
  hub: stack-factory/hub
  spoke: stack-factory/spoke

naming:
  hub_prefix: hub
  spoke_prefix: spoke
  separator: "-"
```

## Examples

### Example 1: Create New Corporate Spoke

```bash
# Initialize the spoke
azlz init spoke \
  --name spoke-corp-prod-005 \
  --environment production \
  --location eastus \
  --address-space 10.5.0.0/16 \
  --hub hub-connectivity-prod

# Validate configuration
azlz validate

# Generate Terraform code
azlz generate spoke-corp-prod-005

# Deploy to Spacelift
azlz deploy spoke-corp-prod-005
```

### Example 2: Batch Create Multiple Spokes

```bash
# Create configuration file
cat > new-spokes.yaml <<EOF
spokes:
  - name: spoke-corp-prod-006
    environment: production
    location: eastus
    address_space: 10.6.0.0/16
    hub: hub-connectivity-prod

  - name: spoke-corp-prod-007
    environment: production
    location: eastus
    address_space: 10.7.0.0/16
    hub: hub-connectivity-prod
EOF

# Import configuration
azlz import new-spokes.yaml

# Validate all
azlz validate

# Deploy all
azlz deploy --all
```

### Example 3: Validate Before Deployment

```bash
# Comprehensive validation
azlz validate --verbose

# Check for CIDR overlaps
azlz validate --check-cidrs

# Verify hub dependencies
azlz validate --check-dependencies
```

## Advanced Usage

### Custom Templates

```bash
# Use custom template
azlz generate spoke-corp-prod-003 \
  --template ./custom-templates/spoke

# List available templates
azlz template list

# Validate template
azlz template validate ./custom-templates/spoke
```

### Integration with Spacelift

```bash
# Check Spacelift stack status
azlz status spoke-corp-prod-003

# View last run
azlz runs spoke-corp-prod-003 --latest

# Trigger run
azlz run spoke-corp-prod-003

# Approve pending run
azlz approve spoke-corp-prod-003
```

### Drift Detection

```bash
# Detect configuration drift
azlz drift spoke-corp-prod-003

# Show differences
azlz drift spoke-corp-prod-003 --show-diff

# Export drift report
azlz drift --all --output drift-report.json
```

## Development

### Running Tests

```bash
# Run unit tests
pytest tests/

# Run with coverage
pytest --cov=azlz tests/

# Run integration tests
pytest tests/integration/
```

### Building

```bash
# Build package
python setup.py sdist bdist_wheel

# Install locally
pip install -e .
```

## Troubleshooting

### Authentication Issues

```bash
# Verify Azure CLI authentication
az account show

# Verify Spacelift credentials
export SPACELIFT_API_KEY_ENDPOINT=https://your-account.app.spacelift.io
export SPACELIFT_API_KEY_ID=your-key-id
export SPACELIFT_API_KEY_SECRET=your-key-secret

azlz config show
```

### Validation Errors

```bash
# Enable debug logging
azlz --debug validate stacks.yaml

# Verbose output
azlz validate --verbose stacks.yaml
```

### Deployment Failures

```bash
# Check stack status in Spacelift
azlz status spoke-corp-prod-003

# View logs
azlz logs spoke-corp-prod-003

# Retry deployment
azlz deploy spoke-corp-prod-003 --retry
```

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for development guidelines.

## License

MIT License - see [LICENSE](../LICENSE) for details.
