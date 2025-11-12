output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.backend.id
}

output "instance_arn" {
  description = "The ARN of the EC2 instance"
  value       = aws_instance.backend.arn
}

output "instance_public_ip" {
  description = "The public IP address of the instance"
  value       = aws_instance.backend.public_ip
}

output "instance_private_ip" {
  description = "The private IP address of the instance"
  value       = aws_instance.backend.private_ip
}

output "instance_public_dns" {
  description = "The public DNS name of the instance"
  value       = aws_instance.backend.public_dns
}

output "instance_private_dns" {
  description = "The private DNS name of the instance"
  value       = aws_instance.backend.private_dns
}

output "elastic_ip" {
  description = "The Elastic IP address (if created)"
  value       = var.create_eip ? aws_eip.backend[0].public_ip : null
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.ec2.id
}

output "security_group_name" {
  description = "The name of the security group"
  value       = aws_security_group.ec2.name
}

output "iam_role_arn" {
  description = "The ARN of the IAM role"
  value       = var.create_iam_role ? aws_iam_role.ec2[0].arn : null
}

output "iam_role_name" {
  description = "The name of the IAM role"
  value       = var.create_iam_role ? aws_iam_role.ec2[0].name : null
}

output "iam_instance_profile_arn" {
  description = "The ARN of the IAM instance profile"
  value       = var.create_iam_role ? aws_iam_instance_profile.ec2[0].arn : null
}

output "key_pair_name" {
  description = "The name of the key pair"
  value       = var.public_key != null ? aws_key_pair.ec2[0].key_name : var.existing_key_name
}

output "availability_zone" {
  description = "The availability zone of the instance"
  value       = aws_instance.backend.availability_zone
}
