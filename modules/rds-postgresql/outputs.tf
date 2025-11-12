output "db_instance_id" {
  description = "The ID of the RDS instance"
  value       = aws_db_instance.postgresql.id
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.postgresql.arn
}

output "db_instance_endpoint" {
  description = "The connection endpoint (hostname:port)"
  value       = aws_db_instance.postgresql.endpoint
}

output "db_instance_address" {
  description = "The hostname of the RDS instance"
  value       = aws_db_instance.postgresql.address
}

output "db_instance_port" {
  description = "The port of the RDS instance"
  value       = aws_db_instance.postgresql.port
}

output "db_instance_name" {
  description = "The database name"
  value       = aws_db_instance.postgresql.db_name
}

output "db_instance_username" {
  description = "The master username"
  value       = aws_db_instance.postgresql.username
  sensitive   = true
}

output "db_instance_password" {
  description = "The master password"
  value       = var.master_password != null ? var.master_password : random_password.master_password[0].result
  sensitive   = true
}

output "db_subnet_group_id" {
  description = "The ID of the DB subnet group"
  value       = aws_db_subnet_group.rds.id
}

output "db_subnet_group_arn" {
  description = "The ARN of the DB subnet group"
  value       = aws_db_subnet_group.rds.arn
}

output "security_group_id" {
  description = "The ID of the RDS security group"
  value       = aws_security_group.rds.id
}

output "security_group_name" {
  description = "The name of the RDS security group"
  value       = aws_security_group.rds.name
}

output "parameter_group_id" {
  description = "The ID of the parameter group"
  value       = var.create_parameter_group ? aws_db_parameter_group.postgresql[0].id : null
}

output "option_group_id" {
  description = "The ID of the option group"
  value       = var.create_option_group ? aws_db_option_group.postgresql[0].id : null
}

output "secrets_manager_secret_arn" {
  description = "ARN of the Secrets Manager secret containing database credentials"
  value       = var.store_password_in_secrets_manager ? aws_secretsmanager_secret.db_password[0].arn : null
}

output "secrets_manager_secret_name" {
  description = "Name of the Secrets Manager secret containing database credentials"
  value       = var.store_password_in_secrets_manager ? aws_secretsmanager_secret.db_password[0].name : null
}

output "connection_string" {
  description = "PostgreSQL connection string (sensitive)"
  value       = "postgresql://${aws_db_instance.postgresql.username}:${var.master_password != null ? var.master_password : random_password.master_password[0].result}@${aws_db_instance.postgresql.address}:${aws_db_instance.postgresql.port}/${aws_db_instance.postgresql.db_name}"
  sensitive   = true
}

output "monitoring_role_arn" {
  description = "ARN of the IAM role for enhanced monitoring"
  value       = var.monitoring_interval > 0 && var.monitoring_role_arn == null ? aws_iam_role.rds_monitoring[0].arn : var.monitoring_role_arn
}
