variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where EC2 instance will be created"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where EC2 instance will be launched"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "associate_public_ip" {
  description = "Associate a public IP address with the instance"
  type        = bool
  default     = true
}

variable "user_data" {
  description = "User data script for instance initialization"
  type        = string
  default     = null
}

variable "user_data_replace_on_change" {
  description = "Replace instance when user data changes"
  type        = bool
  default     = false
}

# Security Group Variables
variable "enable_http" {
  description = "Enable HTTP (port 80) access"
  type        = bool
  default     = true
}

variable "enable_https" {
  description = "Enable HTTPS (port 443) access"
  type        = bool
  default     = true
}

variable "enable_ssh" {
  description = "Enable SSH (port 22) access"
  type        = bool
  default     = true
}

variable "custom_app_port" {
  description = "Custom application port to open"
  type        = number
  default     = null
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the instance (HTTP/HTTPS)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# IAM Variables
variable "create_iam_role" {
  description = "Create IAM role for EC2 instance"
  type        = bool
  default     = true
}

variable "existing_iam_instance_profile" {
  description = "Existing IAM instance profile name (if create_iam_role is false)"
  type        = string
  default     = null
}

variable "enable_ssm" {
  description = "Enable AWS Systems Manager access"
  type        = bool
  default     = true
}

variable "enable_cloudwatch" {
  description = "Enable CloudWatch agent permissions"
  type        = bool
  default     = true
}

variable "custom_iam_policy" {
  description = "Custom IAM policy JSON document"
  type        = string
  default     = null
}

# Key Pair Variables
variable "public_key" {
  description = "Public key content for SSH access (will create new key pair)"
  type        = string
  default     = null
}

variable "existing_key_name" {
  description = "Name of existing key pair to use"
  type        = string
  default     = null
}

# Storage Variables
variable "root_volume_type" {
  description = "Root volume type"
  type        = string
  default     = "gp3"
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 8
}

variable "root_volume_delete_on_termination" {
  description = "Delete root volume on instance termination"
  type        = bool
  default     = true
}

variable "root_volume_encrypted" {
  description = "Encrypt root volume"
  type        = bool
  default     = true
}

# Instance Metadata
variable "imdsv2_required" {
  description = "Require IMDSv2 (more secure metadata service)"
  type        = bool
  default     = true
}

# Monitoring
variable "detailed_monitoring" {
  description = "Enable detailed monitoring (1-minute intervals)"
  type        = bool
  default     = false
}

# Elastic IP
variable "create_eip" {
  description = "Create and associate an Elastic IP"
  type        = bool
  default     = false
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

variable "enable_status_check_alarm" {
  description = "Enable status check alarm"
  type        = bool
  default     = false
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
