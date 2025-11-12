# RDS PostgreSQL Module

This module creates an RDS PostgreSQL database instance with security groups, parameter groups, automated backups, and optional monitoring.

## Features

- RDS PostgreSQL instance with configurable instance class
- Automated password generation and storage in Secrets Manager
- DB subnet group for multi-AZ deployment
- Security group with configurable access rules
- Automated backups with configurable retention
- Optional Multi-AZ deployment for high availability
- Optional Performance Insights
- CloudWatch log exports
- CloudWatch alarms for monitoring
- Encryption at rest

## Usage

### Basic Usage (Cost-Optimized - Single AZ)

```hcl
module "database" {
  source = "./modules/rds-postgresql"

  name_prefix               = "my-app"
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.public_subnet_ids
  source_security_group_id  = module.backend.security_group_id

  # Cost-optimized configuration
  instance_class       = "db.t4g.micro"
  allocated_storage    = 20
  storage_type         = "gp3"
  multi_az             = false  # Single-AZ for cost savings

  # Database
  database_name    = "myapp"
  master_username  = "dbadmin"
  # master_password is auto-generated and stored in Secrets Manager

  # Backups
  backup_retention_period = 7
  skip_final_snapshot     = false

  tags = {
    Environment = "production"
    Project     = "my-app"
  }
}
```

### Production Configuration (Multi-AZ)

```hcl
module "database" {
  source = "./modules/rds-postgresql"

  name_prefix               = "my-app"
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.private_subnet_ids
  source_security_group_id  = module.backend.security_group_id

  # Production configuration
  instance_class       = "db.t4g.small"
  allocated_storage    = 100
  storage_type         = "gp3"
  multi_az             = true  # High availability

  # Database
  database_name    = "production_db"
  master_username  = "dbadmin"

  # Enhanced Monitoring
  monitoring_interval          = 60
  performance_insights_enabled = true

  # Backups
  backup_retention_period = 30
  skip_final_snapshot     = false
  deletion_protection     = true

  # Alarms
  enable_cpu_alarm        = true
  enable_storage_alarm    = true
  enable_connection_alarm = true

  tags = {
    Environment = "production"
  }
}
```

### With Custom Parameters

```hcl
module "database" {
  source = "./modules/rds-postgresql"

  name_prefix               = "my-app"
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.public_subnet_ids
  source_security_group_id  = module.backend.security_group_id

  instance_class    = "db.t4g.micro"
  allocated_storage = 20

  # Custom parameter group
  create_parameter_group = true
  parameter_group_family = "postgres16"

  parameters = [
    {
      name  = "max_connections"
      value = "200"
    },
    {
      name  = "shared_buffers"
      value = "256MB"
    },
    {
      name  = "effective_cache_size"
      value = "1GB"
    },
    {
      name  = "log_min_duration_statement"
      value = "1000"  # Log queries slower than 1 second
    }
  ]

  tags = {
    Environment = "production"
  }
}
```

### Development Configuration (Minimal Cost)

```hcl
module "database" {
  source = "./modules/rds-postgresql"

  name_prefix               = "dev-app"
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.public_subnet_ids
  source_security_group_id  = module.backend.security_group_id

  # Minimal configuration for development
  instance_class          = "db.t4g.micro"
  allocated_storage       = 20
  backup_retention_period = 1  # Minimum backups
  skip_final_snapshot     = true
  deletion_protection     = false
  multi_az                = false

  # Disable monitoring to save costs
  monitoring_interval          = 0
  performance_insights_enabled = false

  tags = {
    Environment = "development"
  }
}
```

## Accessing Database Credentials

### From Terraform Outputs

```hcl
output "database_connection" {
  value = {
    host     = module.database.db_instance_address
    port     = module.database.db_instance_port
    database = module.database.db_instance_name
    username = module.database.db_instance_username
  }
  sensitive = true
}
```

### From AWS Secrets Manager

```bash
# Get secret ARN from Terraform output
aws secretsmanager get-secret-value \
  --secret-id $(terraform output -raw database_secret_arn) \
  --query SecretString \
  --output text | jq -r
```

### Connection String

```bash
# Using environment variables
export PGHOST=$(terraform output -raw db_instance_address)
export PGPORT=$(terraform output -raw db_instance_port)
export PGDATABASE=$(terraform output -raw db_instance_name)
export PGUSER=$(terraform output -raw db_instance_username)
export PGPASSWORD=$(terraform output -raw db_instance_password)

# Connect with psql
psql

# Or use connection string
terraform output -raw connection_string
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name_prefix | Prefix for resource names | string | - | yes |
| vpc_id | VPC ID where RDS will be created | string | - | yes |
| subnet_ids | List of subnet IDs for DB subnet group (min 2) | list(string) | - | yes |
| source_security_group_id | Security group ID allowed to connect | string | - | yes |
| engine_version | PostgreSQL engine version | string | "16.1" | no |
| instance_class | RDS instance class | string | "db.t4g.micro" | no |
| allocated_storage | Allocated storage in GB | number | 20 | no |
| storage_type | Storage type (gp2, gp3, io1) | string | "gp3" | no |
| database_name | Name of the initial database | string | "myapp" | no |
| master_username | Master username | string | "dbadmin" | no |
| master_password | Master password (auto-generated if not provided) | string | null | no |
| multi_az | Enable Multi-AZ deployment | bool | false | no |
| backup_retention_period | Backup retention period in days | number | 7 | no |
| deletion_protection | Enable deletion protection | bool | true | no |

## Outputs

| Name | Description |
|------|-------------|
| db_instance_id | The ID of the RDS instance |
| db_instance_endpoint | The connection endpoint (hostname:port) |
| db_instance_address | The hostname of the RDS instance |
| db_instance_port | The port of the RDS instance |
| db_instance_name | The database name |
| security_group_id | The ID of the RDS security group |
| secrets_manager_secret_arn | ARN of Secrets Manager secret |
| connection_string | PostgreSQL connection string (sensitive) |

## Cost Breakdown

### Monthly Estimated Costs (us-east-1)

**db.t4g.micro (Single-AZ)**:
- Instance: $0.017/hour = $12.82/month
- 2 vCPU, 1 GB RAM

**db.t4g.micro (Multi-AZ)**:
- Instance: $0.034/hour = $24.82/month (double the cost)

**Storage (gp3)**:
- $0.138 per GB/month
- 20 GB = $2.76/month
- 100 GB = $13.80/month

**Backup Storage**:
- Free up to 100% of allocated storage
- Additional: $0.095 per GB/month

**Performance Insights**:
- 7 days retention: Free
- 731 days retention: $0.052 per vCPU/hour

**Data Transfer**:
- Within same AZ: Free
- Cross-AZ: $0.01 per GB (each direction)

**Total Single-AZ Example** (20GB storage, 7-day backups):
- **$15.58/month** (instance + storage)

**Total Multi-AZ Example** (20GB storage, 7-day backups):
- **$27.58/month** (instance + storage)

## Instance Class Comparison

| Class | vCPU | RAM | Price/hour (Single-AZ) | Monthly Cost |
|-------|------|-----|----------------------|--------------|
| db.t4g.micro | 2 | 1 GB | $0.017 | $12.82 |
| db.t4g.small | 2 | 2 GB | $0.034 | $24.82 |
| db.t4g.medium | 2 | 4 GB | $0.068 | $49.64 |

## Cost Optimization Tips

1. **Use Single-AZ**: Save 50% on instance costs (acceptable for dev/staging)
2. **Right-size storage**: Start with 20GB, scale as needed
3. **Use gp3 storage**: Better performance than gp2 at similar cost
4. **Optimize backups**: 7-day retention is usually sufficient
5. **Disable Performance Insights**: Save costs in non-production
6. **Use db.t4g instances**: ARM-based, cheaper than db.t3

## Security Best Practices

1. **Private subnets**: Deploy RDS in private subnets when possible
2. **Security groups**: Only allow access from application security group
3. **Encryption**: Enabled by default in this module
4. **Secrets Manager**: Credentials are automatically stored securely
5. **Deletion protection**: Enabled by default in production
6. **SSL/TLS**: PostgreSQL supports SSL connections by default

## Connecting from Application

### Node.js (pg)

```javascript
const { Client } = require('pg');

const client = new Client({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  ssl: { rejectUnauthorized: false }
});

await client.connect();
```

### Python (psycopg2)

```python
import psycopg2

conn = psycopg2.connect(
    host=os.getenv('DB_HOST'),
    port=os.getenv('DB_PORT'),
    database=os.getenv('DB_NAME'),
    user=os.getenv('DB_USER'),
    password=os.getenv('DB_PASSWORD'),
    sslmode='require'
)
```

## Backup and Recovery

### Manual Snapshot

```bash
aws rds create-db-snapshot \
  --db-instance-identifier my-app-db \
  --db-snapshot-identifier my-app-manual-snapshot-$(date +%Y%m%d)
```

### Restore from Snapshot

```bash
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier my-app-db-restored \
  --db-snapshot-identifier my-app-final-snapshot-2024-01-01
```

## Notes

- db.t4g.micro is the most cost-effective option ($12.82/month)
- Requires minimum 2 subnets in different AZs for DB subnet group
- Password is automatically generated and stored in Secrets Manager
- Multi-AZ deployment doubles the cost but provides high availability
- PostgreSQL 16 is the latest major version (as of 2024)
- Free tier includes 750 hours of db.t2.micro, db.t3.micro, or db.t4g.micro
