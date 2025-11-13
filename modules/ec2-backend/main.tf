# Discover the latest Canonical Ubuntu 22.04 LTS AMI (owner 099720109477)
data "aws_ami" "ubuntu" {
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

# Security Group for EC2 Instance
resource "aws_security_group" "ec2" {
  name_prefix = "${var.name_prefix}-ec2-"
  description = "Security group for ${var.name_prefix} EC2 backend"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-ec2-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Ingress Rules
resource "aws_security_group_rule" "http" {
  count             = var.enable_http ? 1 : 0
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = aws_security_group.ec2.id
  description       = "Allow HTTP traffic"
}

resource "aws_security_group_rule" "https" {
  count             = var.enable_https ? 1 : 0
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = aws_security_group.ec2.id
  description       = "Allow HTTPS traffic"
}

resource "aws_security_group_rule" "ssh" {
  count             = var.enable_ssh ? 1 : 0
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.ssh_cidr_blocks
  security_group_id = aws_security_group.ec2.id
  description       = "Allow SSH access"
}

resource "aws_security_group_rule" "custom_app" {
  count             = var.custom_app_port != null ? 1 : 0
  type              = "ingress"
  from_port         = var.custom_app_port
  to_port           = var.custom_app_port
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = aws_security_group.ec2.id
  description       = "Allow custom application port"
}

# Egress Rule - Allow all outbound traffic
resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2.id
  description       = "Allow all outbound traffic"
}

# IAM Role for EC2
resource "aws_iam_role" "ec2" {
  count = var.create_iam_role ? 1 : 0
  name  = "${var.name_prefix}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Attach AWS managed policies to role
resource "aws_iam_role_policy_attachment" "ssm" {
  count      = var.create_iam_role && var.enable_ssm ? 1 : 0
  role       = aws_iam_role.ec2[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  count      = var.create_iam_role && var.enable_cloudwatch ? 1 : 0
  role       = aws_iam_role.ec2[0].name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Custom IAM policies
resource "aws_iam_role_policy" "custom" {
  count  = var.create_iam_role && var.custom_iam_policy != null ? 1 : 0
  name   = "${var.name_prefix}-custom-policy"
  role   = aws_iam_role.ec2[0].id
  policy = var.custom_iam_policy
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2" {
  count = var.create_iam_role ? 1 : 0
  name  = "${var.name_prefix}-ec2-profile"
  role  = aws_iam_role.ec2[0].name

  tags = var.tags
}

# EC2 Key Pair (if provided)
resource "aws_key_pair" "ec2" {
  count      = var.public_key != null ? 1 : 0
  key_name   = "${var.name_prefix}-key"
  public_key = var.public_key

  tags = var.tags
}

# EC2 Instance
resource "aws_instance" "backend" {
  ami                    = coalesce(var.ami_id, data.aws_ami.ubuntu.id)
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name               = var.public_key != null ? aws_key_pair.ec2[0].key_name : var.existing_key_name

  iam_instance_profile        = var.create_iam_role ? aws_iam_instance_profile.ec2[0].name : var.existing_iam_instance_profile
  associate_public_ip_address = var.associate_public_ip
  user_data                   = var.user_data
  user_data_replace_on_change = var.user_data_replace_on_change

  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    delete_on_termination = var.root_volume_delete_on_termination
    encrypted             = var.root_volume_encrypted

    tags = merge(
      var.tags,
      {
        Name = "${var.name_prefix}-root-volume"
      }
    )
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = var.imdsv2_required ? "required" : "optional"
    http_put_response_hop_limit = 1
  }

  monitoring = var.detailed_monitoring

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-backend"
    }
  )

  volume_tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-backend-volume"
    }
  )

  lifecycle {
    ignore_changes = [ami]
  }
}

# Elastic IP (Optional)
resource "aws_eip" "backend" {
  count    = var.create_eip ? 1 : 0
  instance = aws_instance.backend.id
  domain   = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-backend-eip"
    }
  )
}

# CloudWatch Alarms (Optional)
resource "aws_cloudwatch_metric_alarm" "cpu" {
  count               = var.enable_cpu_alarm ? 1 : 0
  alarm_name          = "${var.name_prefix}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = var.alarm_actions

  dimensions = {
    InstanceId = aws_instance.backend.id
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "status_check" {
  count               = var.enable_status_check_alarm ? 1 : 0
  alarm_name          = "${var.name_prefix}-status-check-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "0"
  alarm_description   = "This metric monitors EC2 instance status checks"
  alarm_actions       = var.alarm_actions

  dimensions = {
    InstanceId = aws_instance.backend.id
  }

  tags = var.tags
}
