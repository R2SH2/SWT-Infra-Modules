# Module Usage Guide

This guide explains how to consume these reusable modules in your infrastructure repositories.

## Table of Contents

- [Repository Structure](#repository-structure)
- [Module Consumption Patterns](#module-consumption-patterns)
- [Environment Structure](#environment-structure)
- [Versioning Strategy](#versioning-strategy)
- [Best Practices](#best-practices)
- [Complete Example](#complete-example)

## Repository Structure

### Recommended Approach: Separate Repositories

```
terraform-modules/          # THIS REPO - Reusable modules
└── modules/
    ├── vpc-networking/
    ├── s3-cloudfront/
    ├── ec2-backend/
    └── rds-postgresql/

my-infrastructure/          # YOUR DEPLOYMENT REPO
├── environments/
│   ├── dev/
│   ├── staging/
│   └── production/
├── terraform.tf            # Provider configuration
└── README.md
```

**Benefits**:
- ✅ Centralized module source of truth
- ✅ Version control and testing
- ✅ Reusability across teams
- ✅ Independent release cycles
- ✅ Clear separation of concerns

## Module Consumption Patterns

### 1. Git Reference (Recommended)

**Pin to specific version**:
```hcl
module "vpc" {
  source = "git::https://github.com/YOUR_ORG/terraform-modules.git//modules/vpc-networking?ref=v1.0.0"

  name_prefix = "myapp-dev"
  # ... other variables
}
```

**Pin to latest on a branch**:
```hcl
module "vpc" {
  source = "git::https://github.com/YOUR_ORG/terraform-modules.git//modules/vpc-networking?ref=main"

  name_prefix = "myapp-dev"
  # ... other variables
}
```

**Pin to specific commit** (most secure):
```hcl
module "vpc" {
  source = "git::https://github.com/YOUR_ORG/terraform-modules.git//modules/vpc-networking?ref=abc123def"

  name_prefix = "myapp-dev"
  # ... other variables
}
```

### 2. Local Path (Development Only)

For local testing during module development:

```hcl
module "vpc" {
  source = "../terraform-modules/modules/vpc-networking"

  name_prefix = "myapp-dev"
  # ... other variables
}
```

⚠️ **Never use local paths in production!**

### 3. Terraform Registry (Enterprise)

If you have Terraform Cloud/Enterprise:

```hcl
module "vpc" {
  source  = "app.terraform.io/YOUR_ORG/vpc-networking/aws"
  version = "1.0.0"

  name_prefix = "myapp-dev"
  # ... other variables
}
```

## Environment Structure

### Directory Layout

```
my-infrastructure/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   ├── staging/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   └── production/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── terraform.tfvars
│       └── backend.tf
├── modules/              # Optional: Environment-specific modules
│   └── app-stack/        # Composition module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── .gitignore
├── .terraform.lock.hcl   # Lock file (committed)
└── README.md
```

### Example: Dev Environment

**environments/dev/main.tf**:
```hcl
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "dev"
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}

# VPC
module "vpc" {
  source = "git::https://github.com/YOUR_ORG/terraform-modules.git//modules/vpc-networking?ref=v1.0.0"

  name_prefix        = "${var.project_name}-dev"
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones

  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  create_nat_gateway = false

  tags = var.tags
}

# Frontend
module "frontend" {
  source = "git::https://github.com/YOUR_ORG/terraform-modules.git//modules/s3-cloudfront?ref=v1.0.0"

  bucket_name            = "${var.project_name}-dev-frontend"
  cloudfront_price_class = "PriceClass_100"

  tags = var.tags
}

// Optional: pin to a specific Ubuntu 22.04 LTS AMI if you do not want the module's auto-discovery
data "aws_ami" "ubuntu_2204" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "backend" {
  source = "git::https://github.com/YOUR_ORG/terraform-modules.git//modules/ec2-backend?ref=v1.0.0"

  name_prefix = "${var.project_name}-dev"
  vpc_id      = module.vpc.vpc_id
  subnet_id   = module.vpc.public_subnet_ids[0]
  # ami_id    = data.aws_ami.ubuntu_2204.id  # Optional override if you enabled the data source above

  instance_type   = "t3.micro"
  custom_app_port = 3000

  tags = var.tags
}

# Database
module "database" {
  source = "git::https://github.com/YOUR_ORG/terraform-modules.git//modules/rds-postgresql?ref=v1.0.0"

  name_prefix              = "${var.project_name}-dev"
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnet_ids
  source_security_group_id = module.backend.security_group_id

  instance_class    = "db.t4g.micro"
  allocated_storage = 20
  multi_az          = false

  database_name   = var.database_name
  master_username = var.database_username

  deletion_protection = false  # Dev environment

  tags = var.tags
}
```

**environments/dev/variables.tf**:
```hcl
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "database_name" {
  description = "Database name"
  type        = string
  default     = "myapp"
}

variable "database_username" {
  description = "Database master username"
  type        = string
  default     = "dbadmin"
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
```

**environments/dev/terraform.tfvars**:
```hcl
project_name = "myapp"
aws_region   = "us-east-1"

tags = {
  Environment = "dev"
  Team        = "platform"
  CostCenter  = "engineering"
}
```

**environments/dev/backend.tf**:
```hcl
terraform {
  backend "s3" {
    bucket         = "mycompany-terraform-state"
    key            = "myapp/dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

**environments/dev/outputs.tf**:
```hcl
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "frontend_url" {
  description = "Frontend CloudFront URL"
  value       = module.frontend.website_url
}

output "backend_ip" {
  description = "Backend EC2 public IP"
  value       = module.backend.instance_public_ip
}

output "database_endpoint" {
  description = "Database endpoint"
  value       = module.database.db_instance_endpoint
  sensitive   = true
}

output "database_secret_arn" {
  description = "Database credentials secret ARN"
  value       = module.database.secrets_manager_secret_arn
}
```

## Versioning Strategy

### Semantic Versioning

Modules follow [SemVer](https://semver.org/):

- **MAJOR** (v1.0.0 → v2.0.0): Breaking changes
- **MINOR** (v1.0.0 → v1.1.0): New features, backward compatible
- **PATCH** (v1.0.0 → v1.0.1): Bug fixes, backward compatible

### Environment Versioning Strategy

**Development**:
```hcl
# Can use latest from main branch
source = "git::https://github.com/YOUR_ORG/terraform-modules.git//modules/vpc-networking?ref=main"
```

**Staging**:
```hcl
# Pin to minor version (auto-get patches)
source = "git::https://github.com/YOUR_ORG/terraform-modules.git//modules/vpc-networking?ref=v1.0"
```

**Production**:
```hcl
# Pin to exact version
source = "git::https://github.com/YOUR_ORG/terraform-modules.git//modules/vpc-networking?ref=v1.0.0"
```

### Upgrading Modules

1. **Check CHANGELOG.md** for breaking changes
2. **Test in dev** environment first
3. **Promote to staging** after validation
4. **Deploy to production** with approval

```bash
# Update module version in dev
# Test thoroughly
terraform plan
terraform apply

# If successful, update staging
# Then production
```

## Best Practices

### 1. Always Pin Versions in Production

❌ **Bad**:
```hcl
source = "git::https://github.com/YOUR_ORG/terraform-modules.git//modules/vpc-networking"
```

✅ **Good**:
```hcl
source = "git::https://github.com/YOUR_ORG/terraform-modules.git//modules/vpc-networking?ref=v1.0.0"
```

### 2. Use Remote State

✅ Store state in S3 with locking:
```hcl
terraform {
  backend "s3" {
    bucket         = "mycompany-terraform-state"
    key            = "myapp/env/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

### 3. Use Consistent Naming

```hcl
name_prefix = "${var.project_name}-${var.environment}"
# Results in: myapp-dev-vpc, myapp-dev-ec2, etc.
```

### 4. Leverage Default Tags

```hcl
provider "aws" {
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
      Team        = var.team
      CostCenter  = var.cost_center
    }
  }
}
```

### 5. Separate Sensitive Values

Use AWS Secrets Manager or Parameter Store:
```hcl
data "aws_secretsmanager_secret_version" "api_key" {
  secret_id = "myapp/api-key"
}

resource "aws_instance" "app" {
  # ...
  user_data = templatefile("user_data.sh", {
    api_key = data.aws_secretsmanager_secret_version.api_key.secret_string
  })
}
```

### 6. Use Workspaces for Temporary Environments

```bash
# Create temporary test environment
terraform workspace new feature-test
terraform apply

# Destroy when done
terraform destroy
terraform workspace select default
terraform workspace delete feature-test
```

### 7. Implement Proper GitOps

```
feature-branch → dev environment
staging branch → staging environment
main branch    → production environment
```

### 8. Cost Tagging

```hcl
tags = {
  Environment = var.environment
  Project     = var.project_name
  CostCenter  = var.cost_center
  Owner       = var.owner
  Terraform   = "true"
}
```

## Complete Example

### Deployment Workflow

```bash
# 1. Clone infrastructure repo
git clone https://github.com/YOUR_ORG/my-infrastructure.git
cd my-infrastructure/environments/dev

# 2. Initialize Terraform
terraform init

# 3. Review changes
terraform plan -out=tfplan

# 4. Apply changes
terraform apply tfplan

# 5. View outputs
terraform output

# 6. Update module version
# Edit main.tf to change ?ref=v1.0.0 to ?ref=v1.1.0

# 7. Re-initialize and upgrade
terraform init -upgrade
terraform plan
terraform apply
```

### CI/CD Pipeline Example (GitHub Actions)

```yaml
name: Terraform Deploy

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  terraform:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: "1.6.0"

      - name: Terraform Init
        run: terraform init
        working-directory: environments/dev

      - name: Terraform Plan
        run: terraform plan
        working-directory: environments/dev

      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        run: terraform apply -auto-approve
        working-directory: environments/dev
```

## Additional Resources

- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Module README Files](./modules/)
- [CONTRIBUTING.md](./CONTRIBUTING.md)

---

**Questions?** Open an issue or discussion in the modules repository.
