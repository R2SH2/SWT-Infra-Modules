# EC2 Backend Module

This module creates an EC2 instance with security groups, IAM roles, and optional monitoring for hosting backend applications.

## Features

- EC2 instance with configurable instance type
- Security group with customizable ingress rules
- IAM role with SSM and CloudWatch permissions
- Optional SSH key pair management
- Optional Elastic IP
- CloudWatch alarms for monitoring
- IMDSv2 enforcement for enhanced security
- Encrypted root volume

## Usage

### Basic Usage (t3.micro for Backend)

```hcl
module "backend" {
  source = "./modules/ec2-backend"

  name_prefix = "my-app"
  vpc_id      = module.vpc.vpc_id
  subnet_id   = module.vpc.public_subnet_ids[0]

  ami_id        = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2023
  instance_type = "t3.micro"

  # Security
  enable_http  = true
  enable_https = true
  enable_ssh   = true

  ssh_cidr_blocks = ["YOUR_IP/32"]  # Restrict SSH to your IP

  tags = {
    Environment = "production"
    Project     = "my-app"
  }
}
```

### With Custom Application Port

```hcl
module "backend" {
  source = "./modules/ec2-backend"

  name_prefix = "my-app"
  vpc_id      = module.vpc.vpc_id
  subnet_id   = module.vpc.public_subnet_ids[0]

  ami_id        = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"

  # Open custom port for your application (e.g., Node.js on 3000)
  custom_app_port     = 3000
  allowed_cidr_blocks = ["0.0.0.0/0"]

  # Restrict SSH
  ssh_cidr_blocks = ["10.0.0.0/16"]  # Only from VPC

  tags = {
    Environment = "production"
  }
}
```

### With User Data (Install Docker & Redis)

```hcl
module "backend" {
  source = "./modules/ec2-backend"

  name_prefix = "my-app"
  vpc_id      = module.vpc.vpc_id
  subnet_id   = module.vpc.public_subnet_ids[0]

  ami_id        = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"

  user_data = <<-EOF
    #!/bin/bash
    # Update system
    yum update -y

    # Install Docker
    yum install -y docker
    systemctl start docker
    systemctl enable docker

    # Install Redis
    docker run -d \
      --name redis \
      --restart unless-stopped \
      -p 6379:6379 \
      redis:alpine

    # Install Docker Compose
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
      -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
  EOF

  tags = {
    Environment = "production"
  }
}
```

### With Elastic IP and Monitoring

```hcl
module "backend" {
  source = "./modules/ec2-backend"

  name_prefix = "my-app"
  vpc_id      = module.vpc.vpc_id
  subnet_id   = module.vpc.public_subnet_ids[0]

  ami_id        = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"

  # Elastic IP for static IP
  create_eip = true

  # Monitoring
  detailed_monitoring      = false  # Keep false to save costs
  enable_cpu_alarm         = true
  cpu_alarm_threshold      = 80
  enable_status_check_alarm = true

  tags = {
    Environment = "production"
  }
}
```

### With Existing SSH Key

```hcl
module "backend" {
  source = "./modules/ec2-backend"

  name_prefix = "my-app"
  vpc_id      = module.vpc.vpc_id
  subnet_id   = module.vpc.public_subnet_ids[0]

  ami_id        = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"

  # Use existing key pair
  existing_key_name = "my-existing-key"

  tags = {
    Environment = "production"
  }
}
```

### With Custom IAM Permissions (S3 Access)

```hcl
module "backend" {
  source = "./modules/ec2-backend"

  name_prefix = "my-app"
  vpc_id      = module.vpc.vpc_id
  subnet_id   = module.vpc.public_subnet_ids[0]

  ami_id        = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"

  custom_iam_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::my-bucket/*"
      }
    ]
  })

  tags = {
    Environment = "production"
  }
}
```

## Finding the Right AMI

Use AWS CLI to find the latest Amazon Linux 2023 AMI:

```bash
aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=al2023-ami-*-x86_64" \
  --query "sort_by(Images, &CreationDate)[-1].[ImageId,Name]" \
  --output text
```

Or use Terraform data source:

```hcl
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "backend" {
  source = "./modules/ec2-backend"

  ami_id = data.aws_ami.amazon_linux_2023.id
  # ... other variables
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name_prefix | Prefix for resource names | string | - | yes |
| vpc_id | VPC ID where EC2 instance will be created | string | - | yes |
| subnet_id | Subnet ID where EC2 instance will be launched | string | - | yes |
| ami_id | AMI ID for the EC2 instance | string | - | yes |
| instance_type | EC2 instance type | string | "t3.micro" | no |
| associate_public_ip | Associate a public IP address | bool | true | no |
| user_data | User data script for initialization | string | null | no |
| enable_http | Enable HTTP (port 80) access | bool | true | no |
| enable_https | Enable HTTPS (port 443) access | bool | true | no |
| enable_ssh | Enable SSH (port 22) access | bool | true | no |
| custom_app_port | Custom application port to open | number | null | no |
| allowed_cidr_blocks | CIDR blocks for HTTP/HTTPS access | list(string) | ["0.0.0.0/0"] | no |
| ssh_cidr_blocks | CIDR blocks for SSH access | list(string) | ["0.0.0.0/0"] | no |
| create_eip | Create and associate an Elastic IP | bool | false | no |
| root_volume_size | Root volume size in GB | number | 8 | no |

## Outputs

| Name | Description |
|------|-------------|
| instance_id | The ID of the EC2 instance |
| instance_public_ip | The public IP address of the instance |
| instance_private_ip | The private IP address of the instance |
| elastic_ip | The Elastic IP address (if created) |
| security_group_id | The ID of the security group |
| iam_role_arn | The ARN of the IAM role |

## Cost Breakdown

### Monthly Estimated Costs (us-east-1)

**t3.micro Instance**:
- On-Demand: $0.0104/hour = $7.59/month
- 2 vCPU, 1 GB RAM

**Storage (gp3)**:
- $0.08 per GB/month
- 8 GB = $0.64/month

**Elastic IP** (if used):
- Free when attached to running instance
- $0.005/hour (~$3.60/month) when not attached

**Data Transfer**:
- First 1 GB/month: Free
- Next 10 TB: $0.09 per GB

**Total Estimate**: ~$8.23/month (instance + storage)

## Security Best Practices

1. **Restrict SSH Access**: Set `ssh_cidr_blocks` to your IP only
2. **Use IMDSv2**: Enabled by default (`imdsv2_required = true`)
3. **Encrypt Root Volume**: Enabled by default
4. **Use Systems Manager**: Enabled by default for secure access without SSH
5. **Regular Updates**: Use user data to update packages on launch

## Accessing the Instance

### Via SSH (if key pair configured):
```bash
ssh -i ~/.ssh/your-key.pem ec2-user@<public-ip>
```

### Via AWS Systems Manager (recommended):
```bash
aws ssm start-session --target <instance-id>
```

## Notes

- t3.micro provides 2 vCPU and 1 GB RAM (suitable for small backends)
- Included in AWS Free Tier (750 hours/month for 12 months)
- For Redis, running it in a Docker container on the same instance saves RDS costs
- Consider using Amazon Linux 2023 for latest features and long-term support
