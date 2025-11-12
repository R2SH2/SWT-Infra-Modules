# VPC Networking Module

This module creates a VPC with public and private subnets, Internet Gateway, and optional NAT Gateway.

## Features

- VPC with configurable CIDR block
- Public subnets with Internet Gateway
- Private subnets with optional NAT Gateway
- Route tables and associations
- Optional VPC Flow Logs
- Multi-AZ support

## Usage

```hcl
module "vpc" {
  source = "./modules/vpc-networking"

  name_prefix        = "my-app"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]

  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]

  create_nat_gateway = false  # Set to true for private subnet internet access

  tags = {
    Environment = "production"
    Project     = "my-app"
  }
}
```

## Cost-Optimized Configuration

For a budget-friendly setup, use public subnets only and skip NAT Gateway:

```hcl
module "vpc" {
  source = "./modules/vpc-networking"

  name_prefix        = "my-app"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]

  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = []

  create_nat_gateway = false

  tags = {
    Environment = "production"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name_prefix | Prefix for resource names | string | - | yes |
| vpc_cidr | CIDR block for VPC | string | "10.0.0.0/16" | no |
| public_subnet_cidrs | List of CIDR blocks for public subnets | list(string) | ["10.0.1.0/24", "10.0.2.0/24"] | no |
| private_subnet_cidrs | List of CIDR blocks for private subnets | list(string) | ["10.0.11.0/24", "10.0.12.0/24"] | no |
| availability_zones | List of availability zones | list(string) | - | yes |
| create_igw | Create Internet Gateway | bool | true | no |
| create_nat_gateway | Create NAT Gateway for private subnets | bool | false | no |
| enable_flow_logs | Enable VPC Flow Logs | bool | false | no |
| tags | Tags to apply to all resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC |
| vpc_cidr | The CIDR block of the VPC |
| public_subnet_ids | List of IDs of public subnets |
| private_subnet_ids | List of IDs of private subnets |
| internet_gateway_id | The ID of the Internet Gateway |
| nat_gateway_ids | List of NAT Gateway IDs |

## Cost Considerations

- **NAT Gateway**: $0.045/hour (~$32.40/month) + data transfer costs
- **VPC, Subnets, IGW, Route Tables**: Free
- **Elastic IP**: Free when attached to a running instance, $0.005/hour when not attached

For cost savings, deploy resources in public subnets and skip NAT Gateway.
