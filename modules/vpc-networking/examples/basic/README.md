# Basic VPC Example

This example demonstrates a basic VPC setup with public and private subnets across two availability zones.

## Features

- VPC with CIDR 10.0.0.0/16
- 2 public subnets
- 2 private subnets
- Internet Gateway
- No NAT Gateway (cost optimization)

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Clean Up

```bash
terraform destroy
```

## Cost

This example costs approximately **$0/month** (VPC resources are free).
