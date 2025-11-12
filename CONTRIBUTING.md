# Contributing to SWT Terraform Modules

Thank you for your interest in contributing! This document provides guidelines and best practices for contributing to this repository.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Module Standards](#module-standards)
- [Testing Requirements](#testing-requirements)
- [Documentation](#documentation)
- [Pull Request Process](#pull-request-process)

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn and grow
- Prioritize security and best practices

## Getting Started

### Prerequisites

- Terraform >= 1.0
- AWS CLI configured
- Git
- Basic understanding of AWS services

### Local Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR_ORG/terraform-modules.git
   cd terraform-modules
   ```

2. **Install development tools**
   ```bash
   # Install terraform-docs
   brew install terraform-docs

   # Install tflint
   brew install tflint

   # Install pre-commit (optional)
   brew install pre-commit
   pre-commit install
   ```

3. **Validate your setup**
   ```bash
   terraform version
   terraform-docs --version
   tflint --version
   ```

## Development Workflow

### 1. Create a Feature Branch

```bash
git checkout -b feature/my-new-module
# or
git checkout -b fix/issue-description
```

### Branch Naming Convention

- `feature/` - New modules or features
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `refactor/` - Code refactoring
- `test/` - Test improvements

### 2. Make Your Changes

Follow the [Module Standards](#module-standards) below.

### 3. Test Your Changes

```bash
# Format your code
terraform fmt -recursive

# Validate syntax
cd modules/your-module
terraform init -backend=false
terraform validate

# Run linting
tflint

# Generate documentation
terraform-docs markdown table . > README.md
```

### 4. Commit Your Changes

Use [Conventional Commits](https://www.conventionalcommits.org/):

```bash
git commit -m "feat(vpc): add support for VPC endpoints"
git commit -m "fix(rds): correct backup retention period validation"
git commit -m "docs(ec2): add production configuration example"
```

**Commit Types:**
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation only
- `refactor:` - Code refactoring
- `test:` - Adding tests
- `chore:` - Maintenance tasks

### 5. Push and Create Pull Request

```bash
git push origin feature/my-new-module
```

Then create a Pull Request on GitHub.

## Module Standards

### Directory Structure

Every module must follow this structure:

```
modules/module-name/
├── main.tf           # Main resources
├── variables.tf      # Input variables
├── outputs.tf        # Output values
├── versions.tf       # Provider requirements
├── README.md         # Module documentation
└── examples/
    ├── basic/        # Basic usage example
    │   ├── main.tf
    │   ├── variables.tf
    │   └── README.md
    └── complete/     # Advanced usage example
        ├── main.tf
        ├── variables.tf
        └── README.md
```

### File Standards

#### variables.tf

```hcl
variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string

  validation {
    condition     = length(var.name_prefix) <= 20
    error_message = "Name prefix must be 20 characters or less."
  }
}

variable "enable_monitoring" {
  description = "Enable CloudWatch monitoring"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
```

**Variable Requirements:**
- Always include `description`
- Use appropriate `type` constraints
- Provide sensible `default` values for optional variables
- Add `validation` blocks for complex constraints
- Mark sensitive variables with `sensitive = true`

#### outputs.tf

```hcl
output "resource_id" {
  description = "The ID of the created resource"
  value       = aws_resource.main.id
}

output "resource_arn" {
  description = "The ARN of the created resource"
  value       = aws_resource.main.arn
}
```

**Output Requirements:**
- Always include `description`
- Mark sensitive outputs with `sensitive = true`
- Use descriptive names

#### main.tf

```hcl
# Group related resources together
# Add comments for complex logic
# Use locals for computed values

locals {
  common_tags = merge(
    var.tags,
    {
      ManagedBy = "Terraform"
      Module    = "module-name"
    }
  )
}

resource "aws_resource" "main" {
  name = "${var.name_prefix}-resource"

  # Use dynamic blocks for optional features
  dynamic "optional_block" {
    for_each = var.enable_feature ? [1] : []
    content {
      # configuration
    }
  }

  tags = local.common_tags
}
```

#### versions.tf

```hcl
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}
```

### Naming Conventions

- **Resources**: `snake_case` (e.g., `aws_vpc`, `security_group`)
- **Variables**: `snake_case` (e.g., `vpc_cidr`, `enable_monitoring`)
- **Outputs**: `snake_case` (e.g., `vpc_id`, `subnet_ids`)
- **Files**: `snake_case.tf` (e.g., `main.tf`, `variables.tf`)

### Tagging Strategy

All resources must support tags:

```hcl
tags = merge(
  var.tags,
  {
    Name      = "${var.name_prefix}-resource-name"
    ManagedBy = "Terraform"
  }
)
```

### Security Best Practices

- ✅ Enable encryption by default
- ✅ Use private subnets for databases
- ✅ Restrict security group rules
- ✅ Use IMDSv2 for EC2 instances
- ✅ Store secrets in Secrets Manager
- ✅ Enable deletion protection for production resources
- ❌ Never hardcode credentials
- ❌ Never use `0.0.0.0/0` for SSH access by default

### Cost Optimization

- Provide cost-optimized defaults
- Document cost implications in README
- Include cost comparison tables
- Offer toggles for expensive features (Multi-AZ, NAT Gateway, etc.)

## Testing Requirements

### Manual Testing

Before submitting a PR:

1. **Format Check**
   ```bash
   terraform fmt -check -recursive
   ```

2. **Validation**
   ```bash
   cd modules/your-module
   terraform init -backend=false
   terraform validate
   ```

3. **Linting**
   ```bash
   tflint
   ```

4. **Example Testing**
   ```bash
   cd modules/your-module/examples/basic
   terraform init
   terraform plan
   terraform apply  # If safe to test
   terraform destroy
   ```

### Automated Testing (CI/CD)

Pull requests automatically run:
- Terraform fmt check
- Terraform validate
- Security scanning (tfsec)
- Documentation validation

## Documentation

### Module README Template

Each module's README should include:

1. **Description** - What the module does
2. **Features** - Key features and capabilities
3. **Usage** - Basic and advanced examples
4. **Inputs** - Table of variables
5. **Outputs** - Table of outputs
6. **Cost Breakdown** - Monthly cost estimates
7. **Security** - Security considerations
8. **Notes** - Important notes and limitations

### Auto-generating Documentation

Use `terraform-docs`:

```bash
cd modules/your-module
terraform-docs markdown table . > README.md
```

### Code Comments

- Add comments for complex logic
- Explain "why" not "what"
- Document workarounds or non-obvious solutions

## Pull Request Process

### Before Submitting

- [ ] Code is formatted (`terraform fmt`)
- [ ] Code is validated (`terraform validate`)
- [ ] Linting passes (`tflint`)
- [ ] Documentation is updated
- [ ] Examples are provided
- [ ] CHANGELOG.md is updated
- [ ] All tests pass locally

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] New module
- [ ] Bug fix
- [ ] Feature enhancement
- [ ] Documentation update
- [ ] Breaking change

## Testing
Describe how you tested your changes

## Checklist
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] Examples provided
- [ ] CHANGELOG.md updated
- [ ] No breaking changes (or documented)

## Cost Impact
Describe any cost implications

## Security Considerations
List any security considerations
```

### Review Process

1. **Automated Checks** - CI/CD pipeline runs
2. **Code Review** - At least one approval required
3. **Testing** - Reviewers may test changes
4. **Merge** - Squash and merge to main

### After Merge

- Tag release if needed (maintainers only)
- Update CHANGELOG.md
- Close related issues

## Versioning

We use [Semantic Versioning](https://semver.org/):

- **MAJOR** (1.0.0 → 2.0.0) - Breaking changes
- **MINOR** (1.0.0 → 1.1.0) - New features, backwards compatible
- **PATCH** (1.0.0 → 1.0.1) - Bug fixes, backwards compatible

### Release Process

1. Update CHANGELOG.md
2. Create Git tag: `git tag -a v1.0.0 -m "Release v1.0.0"`
3. Push tag: `git push origin v1.0.0`
4. Create GitHub release with notes

## Getting Help

- **Questions**: Open a [Discussion](https://github.com/YOUR_ORG/terraform-modules/discussions)
- **Bugs**: Open an [Issue](https://github.com/YOUR_ORG/terraform-modules/issues)
- **Features**: Open a [Feature Request](https://github.com/YOUR_ORG/terraform-modules/issues/new?template=feature_request.md)

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for contributing to SWT Terraform Modules!** 🎉
