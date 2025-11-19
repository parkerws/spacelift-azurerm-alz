# Contributing to Spacelift Azure Landing Zone Factory

## Development Setup

### Prerequisites

- Terraform >= 1.9.0 or OpenTofu >= 1.8.0
- Azure CLI
- Git
- An Azure subscription for testing
- Spacelift account (for integration testing)

### Local Development

1. Clone the repository:
```bash
git clone https://github.com/your-org/spacelift-azurerm-alz.git
cd spacelift-azurerm-alz
```

2. Set up Azure authentication:
```bash
az login
az account set --subscription "your-subscription-id"
```

## Module Development Guidelines

### Module Structure

Each module MUST follow this structure:

```
modules/category/azure-resource/
├── .spacelift/
│   └── config.yml          # Spacelift module configuration
├── examples/
│   ├── basic/              # Basic usage example
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   └── advanced/           # Advanced/complete example
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── versions.tf
├── tests/                  # Automated tests (optional)
│   └── basic_test.go
├── main.tf                 # Primary resource definitions
├── variables.tf            # Input variable definitions
├── outputs.tf              # Output definitions
├── versions.tf             # Provider version constraints
├── locals.tf               # Local values (if needed)
└── README.md               # Module documentation
```

### Module Requirements

1. **Variables**:
   - Use descriptions from Terraform azurerm provider documentation
   - Include validation rules where appropriate
   - Provide sensible defaults for optional variables
   - Use descriptive variable names (no single letters)

2. **Outputs**:
   - MINIMUM: `id` and `name` of the primary resource
   - Include contextual outputs (e.g., `kubeconfig` for AKS, `connection_string` for storage)
   - Use descriptions for all outputs
   - Output entire resource object as `this` for advanced use cases

3. **Naming**:
   - Support external naming via `name` variable
   - Do NOT enforce naming conventions in modules (handle in stack factory)
   - Allow flexibility for different naming patterns

4. **Tagging**:
   - Include a `tags` variable of type `map(string)`
   - Apply tags to all taggable resources
   - Do NOT enforce required tags in modules

5. **Documentation**:
   - Include comprehensive README.md with:
     - Description
     - Usage examples
     - Requirements
     - Inputs table
     - Outputs table
     - Resources created
   - Use terraform-docs format (will be auto-generated)

### Testing

Each module MUST include:

1. **Basic Example**: Minimal configuration demonstrating core functionality
2. **Advanced Example**: Complex configuration showing all features
3. **Test Cases**: In `.spacelift/config.yml` for Spacelift-based testing

Example test configuration:
```yaml
version: 1
tests:
  - name: basic
    command: cd examples/basic && terraform init && terraform plan
  - name: advanced
    command: cd examples/advanced && terraform init && terraform plan
```

### Code Style

1. **Formatting**: Use `terraform fmt -recursive` before committing
2. **Validation**: Run `terraform validate` on all modules and examples
3. **Linting**: Use `tflint` with Azure ruleset
4. **Documentation**: Auto-generate docs with `terraform-docs`

### Commit Guidelines

Follow Conventional Commits:

```
feat(module-name): add support for feature X
fix(azure-vnet): correct DDoS protection plan association
docs(readme): update usage examples
test(azure-firewall): add multi-IP test case
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `test`: Adding or updating tests
- `refactor`: Code refactoring
- `chore`: Maintenance tasks

### Pull Request Process

1. Create a feature branch: `git checkout -b feat/your-feature`
2. Make your changes following guidelines above
3. Run tests: `terraform fmt -recursive && terraform validate`
4. Update documentation
5. Commit with conventional commits
6. Push and create PR
7. Ensure CI passes
8. Request review from maintainers

### Module Approval Checklist

- [ ] Follows module structure
- [ ] Includes at minimum `id` and `name` outputs
- [ ] Includes contextual outputs appropriate for resource
- [ ] Has basic and advanced examples
- [ ] Examples are tested and working
- [ ] README.md is comprehensive
- [ ] Variables have descriptions from provider docs
- [ ] Code is formatted (`terraform fmt`)
- [ ] Code is validated (`terraform validate`)
- [ ] `.spacelift/config.yml` includes test cases
- [ ] No hardcoded values
- [ ] Supports tags via variable
- [ ] Uses latest azurerm provider features

## Policy Development

Policies should be:
- Written in Rego (OPA)
- Well-documented with examples
- Tested against sample Terraform plans
- Include both allow and deny test cases

## Questions?

Open a discussion on GitHub or reach out to the maintainers.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
