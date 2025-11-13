# Local variables
locals {
  # Handle password logic: use provided password or generate a random one
  # This prevents "value is marked" errors during validation
  db_password = var.master_password != null ? var.master_password : try(random_password.master_password[0].result, "")
}

# DB Subnet Group
resource "aws_db_subnet_group" "rds" {
  name       = "${var.name_prefix}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-db-subnet-group"
    }
  )
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name_prefix = "${var.name_prefix}-rds-"
  description = "Security group for ${var.name_prefix} RDS PostgreSQL"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-rds-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Ingress rule for PostgreSQL
resource "aws_security_group_rule" "rds_ingress" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = var.source_security_group_id
  description              = "Allow PostgreSQL access from application"
}

# Ingress rule from CIDR blocks (optional)
resource "aws_security_group_rule" "rds_ingress_cidr" {
  count             = length(var.allowed_cidr_blocks) > 0 ? 1 : 0
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = aws_security_group.rds.id
  description       = "Allow PostgreSQL access from CIDR blocks"
}

# Egress rule - Allow all outbound
resource "aws_security_group_rule" "rds_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rds.id
  description       = "Allow all outbound traffic"
}

# Random password for master user
resource "random_password" "master_password" {
  count   = var.master_password == null ? 1 : 0
  length  = 16
  special = true
  # Avoid characters that might cause issues in connection strings
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Store password in Secrets Manager
resource "aws_secretsmanager_secret" "db_password" {
  count                   = var.store_password_in_secrets_manager ? 1 : 0
  name                    = "${var.name_prefix}-db-password"
  description             = "RDS master password for ${var.name_prefix}"
  recovery_window_in_days = var.password_secret_recovery_window

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "db_password" {
  count     = var.store_password_in_secrets_manager ? 1 : 0
  secret_id = aws_secretsmanager_secret.db_password[0].id
  secret_string = jsonencode({
    username = var.master_username
    password = local.db_password
    engine   = "postgres"
    host     = aws_db_instance.postgresql.address
    port     = aws_db_instance.postgresql.port
    dbname   = var.database_name
  })
}

# Parameter Group
resource "aws_db_parameter_group" "postgresql" {
  count       = var.create_parameter_group ? 1 : 0
  name        = "${var.name_prefix}-pg-params"
  family      = var.parameter_group_family
  description = "Parameter group for ${var.name_prefix} PostgreSQL"

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", "immediate")
    }
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# Option Group (PostgreSQL has limited options)
resource "aws_db_option_group" "postgresql" {
  count                    = var.create_option_group ? 1 : 0
  name                     = "${var.name_prefix}-pg-options"
  engine_name              = "postgres"
  major_engine_version     = var.major_engine_version
  option_group_description = "Option group for ${var.name_prefix} PostgreSQL"

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# RDS Instance
resource "aws_db_instance" "postgresql" {
  identifier = "${var.name_prefix}-db"

  # Engine
  engine             = "postgres"
  engine_version     = var.engine_version
  instance_class     = var.instance_class
  allocated_storage  = var.allocated_storage
  storage_type       = var.storage_type
  storage_encrypted  = var.storage_encrypted
  kms_key_id         = var.kms_key_id
  iops               = var.iops
  storage_throughput = var.storage_throughput

  # Database
  db_name  = var.database_name
  username = var.master_username
  password = local.db_password
  port     = var.database_port

  # Network & Security
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = var.publicly_accessible

  # Parameter & Option Groups
  parameter_group_name = var.create_parameter_group ? aws_db_parameter_group.postgresql[0].name : var.parameter_group_name
  option_group_name    = var.create_option_group ? aws_db_option_group.postgresql[0].name : var.option_group_name

  # Backup
  backup_retention_period   = var.backup_retention_period
  backup_window             = var.backup_window
  copy_tags_to_snapshot     = true
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.name_prefix}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  # Maintenance
  maintenance_window          = var.maintenance_window
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  allow_major_version_upgrade = var.allow_major_version_upgrade
  apply_immediately           = var.apply_immediately
  deletion_protection         = var.deletion_protection
  delete_automated_backups    = var.delete_automated_backups

  # Monitoring
  enabled_cloudwatch_logs_exports       = var.enabled_cloudwatch_logs_exports
  monitoring_interval                   = var.monitoring_interval
  monitoring_role_arn                   = var.monitoring_interval > 0 ? var.monitoring_role_arn != null ? var.monitoring_role_arn : aws_iam_role.rds_monitoring[0].arn : null
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null

  # Multi-AZ
  multi_az = var.multi_az

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-postgresql"
    }
  )

  lifecycle {
    ignore_changes = [final_snapshot_identifier]
  }
}

# IAM Role for Enhanced Monitoring
resource "aws_iam_role" "rds_monitoring" {
  count = var.monitoring_interval > 0 && var.monitoring_role_arn == null ? 1 : 0
  name  = "${var.name_prefix}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  count      = var.monitoring_interval > 0 && var.monitoring_role_arn == null ? 1 : 0
  role       = aws_iam_role.rds_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "cpu" {
  count               = var.enable_cpu_alarm ? 1 : 0
  alarm_name          = "${var.name_prefix}-rds-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
  alarm_description   = "This metric monitors RDS CPU utilization"
  alarm_actions       = var.alarm_actions

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.postgresql.id
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "storage" {
  count               = var.enable_storage_alarm ? 1 : 0
  alarm_name          = "${var.name_prefix}-rds-low-storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.storage_alarm_threshold * 1024 * 1024 * 1024 # Convert GB to bytes
  alarm_description   = "This metric monitors RDS free storage space"
  alarm_actions       = var.alarm_actions

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.postgresql.id
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "connections" {
  count               = var.enable_connection_alarm ? 1 : 0
  alarm_name          = "${var.name_prefix}-rds-high-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.connection_alarm_threshold
  alarm_description   = "This metric monitors RDS database connections"
  alarm_actions       = var.alarm_actions

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.postgresql.id
  }

  tags = var.tags
}
