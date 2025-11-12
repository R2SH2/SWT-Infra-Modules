# SWT Terraform Modules

A collection of reusable Terraform modules for deploying cost-optimized web application infrastructure on AWS.

## Architecture Overview

These modules implement a complete web application stack with the following components:

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  ┌──────────────┐         ┌─────────────────────────────────┐  │
│  │              │         │         CloudFront CDN          │  │
│  │   Internet   │────────▶│    (Global Edge Locations)     │  │
│  │              │         │                                 │  │
│  └──────────────┘         └─────────────┬───────────────────┘  │
│                                         │                       │
│                           ┌─────────────▼──────────┐           │
│                           │      S3 Bucket         │           │
│                           │  (Static Frontend)     │           │
│                           └────────────────────────┘           │
│                                                                 │
│  ┌─────────────────────── VPC ────────────────────────────┐   │
│  │                                                         │   │
│  │  ┌─────────────────────────────────────────────────┐   │   │
│  │  │         Public Subnet (10.0.1.0/24)             │   │   │
│  │  │                                                   │   │   │
│  │  │  ┌────────────────────┐                          │   │   │
│  │  │  │   EC2 t3.micro     │                          │   │   │
│  │  │  │  Backend + Redis   │◀─────── Internet        │   │   │
│  │  │  │    (Docker)        │         Gateway         │   │   │
│  │  │  └──────────┬─────────┘                          │   │   │
│  │  └─────────────┼──────────────────────────────────┘   │   │
│  │                │                                        │   │
│  │                │                                        │   │
│  │  ┌─────────────▼──────────────────────────────────┐   │   │
│  │  │      Private Subnet (10.0.11.0/24)             │   │   │
│  │  │                                                   │   │   │
│  │  │  ┌────────────────────────────────────┐         │   │   │
│  │  │  │   RDS PostgreSQL (db.t4g.micro)    │         │   │   │
│  │  │  │      Single-AZ, 20GB gp3           │         │   │   │
│  │  │  └────────────────────────────────────┘         │   │   │
│  │  └─────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## Cost Breakdown

| Component | Service | Specs | Monthly Cost |
|-----------|---------|-------|--------------|
| Frontend | S3 + CloudFront | Static hosting | $3-5 |
| Backend | t3.micro EC2 | 2 vCPU, 1GB RAM | $7.59 |
| Redis | On EC2 | Embedded in Docker | $0 |
| Database | RDS t4g.micro | Single-AZ PostgreSQL | $12.82 |
| RDS Storage | gp3 20GB | Database storage | $2.76 |
| **Total** | | | **$26.17-28.17** |

## Available Modules

| Module | Description | Use Cases |
|--------|-------------|-----------|
| [vpc-networking](./modules/vpc-networking) | VPC with public/private subnets, NAT gateways | Foundation for all AWS infrastructure |
| [s3-cloudfront](./modules/s3-cloudfront) | S3 + CloudFront CDN | Static websites, SPAs |
| [ec2-backend](./modules/ec2-backend) | EC2 instance with security groups and IAM | Backend applications |
| [rds-postgresql](./modules/rds-postgresql) | RDS PostgreSQL database | Relational database workloads |

## Quick Start

### 1. VPC Networking Module

Creates the foundational VPC infrastructure:

```hcl
module "vpc" {
  source = "./modules/vpc-networking"

  name_prefix        = "my-app"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]

  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]

  create_nat_gateway = false  # Save costs

  tags = {
    Environment = "production"
    Project     = "my-app"
  }
}
```

### 2. S3 + CloudFront Module

Deploy your static frontend:

```hcl
module "frontend" {
  source = "./modules/s3-cloudfront"

  bucket_name            = "my-unique-app-bucket"
  cloudfront_price_class = "PriceClass_100"

  # Support SPA routing
  custom_error_responses = [
    {
      error_code            = 404
      response_code         = 200
      response_page_path    = "/index.html"
      error_caching_min_ttl = 300
    }
  ]

  tags = {
    Environment = "production"
  }
}
```

### 3. EC2 Backend Module

Create your backend server:

```hcl
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

module "backend" {
  source = "./modules/ec2-backend"

  name_prefix = "my-app"
  vpc_id      = module.vpc.vpc_id
  subnet_id   = module.vpc.public_subnet_ids[0]
  ami_id      = data.aws_ami.amazon_linux_2023.id

  instance_type   = "t3.micro"
  custom_app_port = 3000

  # Install Docker and Redis
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    systemctl start docker
    systemctl enable docker

    docker run -d \
      --name redis \
      --restart unless-stopped \
      -p 6379:6379 \
      redis:alpine
  EOF

  tags = {
    Environment = "production"
  }
}
```

### 4. RDS PostgreSQL Module

Add a managed database:

```hcl
module "database" {
  source = "./modules/rds-postgresql"

  name_prefix              = "my-app"
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnet_ids
  source_security_group_id = module.backend.security_group_id

  instance_class    = "db.t4g.micro"
  allocated_storage = 20
  storage_type      = "gp3"
  multi_az          = false

  database_name   = "myapp"
  master_username = "dbadmin"

  backup_retention_period = 7
  deletion_protection     = true

  tags = {
    Environment = "production"
  }
}
```

## Complete Example

Here's a complete example deploying the full stack:

```hcl
# main.tf
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  name_prefix = "my-app"
  environment = "production"

  tags = {
    Environment = local.environment
    Project     = local.name_prefix
    ManagedBy   = "Terraform"
  }
}

# VPC
module "vpc" {
  source = "./modules/vpc-networking"

  name_prefix        = local.name_prefix
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]

  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]

  create_nat_gateway = false

  tags = local.tags
}

# Frontend
module "frontend" {
  source = "./modules/s3-cloudfront"

  bucket_name            = "${local.name_prefix}-frontend"
  cloudfront_price_class = "PriceClass_100"

  tags = local.tags
}

# Get latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# Backend EC2
module "backend" {
  source = "./modules/ec2-backend"

  name_prefix = local.name_prefix
  vpc_id      = module.vpc.vpc_id
  subnet_id   = module.vpc.public_subnet_ids[0]
  ami_id      = data.aws_ami.amazon_linux_2023.id

  instance_type   = "t3.micro"
  custom_app_port = 3000

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    systemctl start docker
    systemctl enable docker

    docker run -d \
      --name redis \
      --restart unless-stopped \
      -p 6379:6379 \
      redis:alpine
  EOF

  tags = local.tags
}

# Database
module "database" {
  source = "./modules/rds-postgresql"

  name_prefix              = local.name_prefix
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnet_ids
  source_security_group_id = module.backend.security_group_id

  instance_class    = "db.t4g.micro"
  allocated_storage = 20
  storage_type      = "gp3"
  multi_az          = false

  database_name   = "myapp"
  master_username = "dbadmin"

  backup_retention_period = 7
  deletion_protection     = true

  tags = local.tags
}

# Outputs
output "frontend_url" {
  description = "CloudFront URL for frontend"
  value       = module.frontend.website_url
}

output "backend_public_ip" {
  description = "Public IP of backend EC2"
  value       = module.backend.instance_public_ip
}

output "database_endpoint" {
  description = "Database connection endpoint"
  value       = module.database.db_instance_endpoint
}

output "database_secret_arn" {
  description = "ARN of database credentials in Secrets Manager"
  value       = module.database.secrets_manager_secret_arn
}
```

## Deployment Steps

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Review the Plan

```bash
terraform plan
```

### 3. Apply the Configuration

```bash
terraform apply
```

### 4. Deploy Frontend

```bash
# Build your frontend (example: React)
npm run build

# Upload to S3
aws s3 sync ./build s3://your-bucket-name --delete

# Invalidate CloudFront cache
aws cloudfront create-invalidation \
  --distribution-id YOUR_DISTRIBUTION_ID \
  --paths "/*"
```

### 5. Deploy Backend

```bash
# SSH into EC2 instance
ssh -i ~/.ssh/your-key.pem ec2-user@<backend-ip>

# Clone your application
git clone https://github.com/your/repo.git
cd repo

# Run with Docker
docker build -t myapp .
docker run -d \
  -p 3000:3000 \
  -e DATABASE_URL="postgresql://..." \
  myapp
```

## Prerequisites

- Terraform >= 1.0
- AWS CLI >= 2.0 (configured with credentials)
- AWS account with appropriate permissions

## Cost Optimization Tips

1. **Use Single-AZ for RDS**: Save 50% on database costs
2. **Skip NAT Gateway**: Deploy in public subnets where possible (~$32/month savings)
3. **Use t4g instances**: ARM-based instances are 20% cheaper
4. **Optimize CloudFront**: Use PriceClass_100 for North America/Europe only
5. **Right-size storage**: Start with 20GB and scale as needed
6. **Use Free Tier**: Many services have 12-month free tier
7. **Run Redis on EC2**: Avoid ElastiCache costs (~$13/month savings)
8. **Disable detailed monitoring**: Use standard 5-minute metrics

## AWS Free Tier Benefits

These modules maximize AWS Free Tier usage:

- **EC2**: 750 hours/month of t2.micro, t3.micro, or t4g.micro (12 months)
- **RDS**: 750 hours/month of db.t2.micro, db.t3.micro, or db.t4g.micro (12 months)
- **S3**: 5 GB storage, 20,000 GET requests, 2,000 PUT requests (12 months)
- **CloudFront**: 1 TB data transfer out, 10M HTTP/HTTPS requests (always free)
- **VPC**: VPC, subnets, route tables, security groups (always free)

## Security Best Practices

All modules include:

- **Encryption at Rest**: All data encrypted by default
- **Private Networking**: RDS deployed in private subnets
- **Least Privilege IAM**: Minimal required permissions
- **Security Group Rules**: Restrictive ingress/egress
- **Secrets Manager**: Database credentials stored securely
- **IMDSv2**: Enhanced security for EC2 metadata
- **CloudWatch Logging**: Comprehensive audit trails

## Module Dependencies

```
vpc-networking (base)
    ├── ec2-backend (requires: vpc_id, subnet_id)
    ├── rds-postgresql (requires: vpc_id, subnet_ids)
    └── s3-cloudfront (independent)
```

## License

MIT License - feel free to use these modules in your projects.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

For issues and questions:
- Check individual module READMEs for detailed documentation
- Review AWS documentation for service-specific details
- Open an issue in this repository

## Version History

- **v1.0.0** - Initial release with VPC, S3+CloudFront, EC2, and RDS modules

## Author

SWT Infrastructure Team
