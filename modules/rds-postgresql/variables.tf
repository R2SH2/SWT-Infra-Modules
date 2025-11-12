variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where RDS will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for DB subnet group (minimum 2 subnets in different AZs)"
  type        = list(string)
}

variable "source_security_group_id" {
  description = "Security group ID that will be allowed to connect to RDS"
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "Additional CIDR blocks allowed to connect to RDS"
  type        = list(string)
  default     = []
}

# Database Configuration
variable "engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "16.1"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "storage_type" {
  description = "Storage type (gp2, gp3, io1)"
  type        = string
  default     = "gp3"
}

variable "storage_encrypted" {
  description = "Enable storage encryption"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ID for storage encryption (if not specified, default key is used)"
  type        = string
  default     = null
}

variable "iops" {
  description = "IOPS for io1 storage type"
  type        = number
  default     = null
}

variable "storage_throughput" {
  description = "Storage throughput for gp3 (MiB/s)"
  type        = number
  default     = null
}

variable "database_name" {
  description = "Name of the initial database"
  type        = string
  default     = "myapp"
}

variable "master_username" {
  description = "Master username for the database"
  type        = string
  default     = "dbadmin"
}

variable "master_password" {
  description = "Master password (if not provided, will be auto-generated)"
  type        = string
  default     = null
  sensitive   = true
}

variable "database_port" {
  description = "Database port"
  type        = number
  default     = 5432
}

variable "publicly_accessible" {
  description = "Make database publicly accessible"
  type        = bool
  default     = false
}

# Backup Configuration
variable "backup_retention_period" {
  description = "Backup retention period in days (0 to disable)"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Preferred backup window (UTC)"
  type        = string
  default     = "03:00-04:00"
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when destroying"
  type        = bool
  default     = false
}

# Maintenance
variable "maintenance_window" {
  description = "Preferred maintenance window (UTC)"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "auto_minor_version_upgrade" {
  description = "Enable automatic minor version upgrades"
  type        = bool
  default     = true
}

variable "allow_major_version_upgrade" {
  description = "Allow major version upgrades"
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Apply changes immediately (may cause downtime)"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}

variable "delete_automated_backups" {
  description = "Delete automated backups on instance deletion"
  type        = bool
  default     = true
}

# Monitoring
variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to export to CloudWatch (postgresql, upgrade)"
  type        = list(string)
  default     = ["postgresql"]
}

variable "monitoring_interval" {
  description = "Enhanced monitoring interval in seconds (0, 1, 5, 10, 15, 30, 60)"
  type        = number
  default     = 0
}

variable "monitoring_role_arn" {
  description = "IAM role ARN for enhanced monitoring (if not provided, will be created)"
  type        = string
  default     = null
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights"
  type        = bool
  default     = false
}

variable "performance_insights_retention_period" {
  description = "Performance Insights retention period in days (7 or 731)"
  type        = number
  default     = 7
}

# Multi-AZ
variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = false
}

# Parameter Group
variable "create_parameter_group" {
  description = "Create a custom parameter group"
  type        = bool
  default     = false
}

variable "parameter_group_name" {
  description = "Name of existing parameter group to use (if create_parameter_group is false)"
  type        = string
  default     = null
}

variable "parameter_group_family" {
  description = "Parameter group family"
  type        = string
  default     = "postgres16"
}

variable "parameters" {
  description = "List of parameters for the parameter group"
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string, "immediate")
  }))
  default = []
}

# Option Group
variable "create_option_group" {
  description = "Create a custom option group"
  type        = bool
  default     = false
}

variable "option_group_name" {
  description = "Name of existing option group to use (if create_option_group is false)"
  type        = string
  default     = null
}

variable "major_engine_version" {
  description = "Major engine version for option group"
  type        = string
  default     = "16"
}

# Secrets Manager
variable "store_password_in_secrets_manager" {
  description = "Store database credentials in AWS Secrets Manager"
  type        = bool
  default     = true
}

variable "password_secret_recovery_window" {
  description = "Recovery window for Secrets Manager secret deletion (days)"
  type        = number
  default     = 7
}

# CloudWatch Alarms
variable "enable_cpu_alarm" {
  description = "Enable CPU utilization alarm"
  type        = bool
  default     = false
}

variable "cpu_alarm_threshold" {
  description = "CPU utilization threshold for alarm (percentage)"
  type        = number
  default     = 80
}

variable "enable_storage_alarm" {
  description = "Enable free storage space alarm"
  type        = bool
  default     = false
}

variable "storage_alarm_threshold" {
  description = "Free storage space threshold for alarm (GB)"
  type        = number
  default     = 5
}

variable "enable_connection_alarm" {
  description = "Enable database connections alarm"
  type        = bool
  default     = false
}

variable "connection_alarm_threshold" {
  description = "Database connections threshold for alarm"
  type        = number
  default     = 80
}

variable "alarm_actions" {
  description = "List of ARNs to notify when alarm triggers"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
