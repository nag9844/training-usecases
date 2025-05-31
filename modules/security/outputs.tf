# Outputs from the Security module

output "alb_security_group_id" {
  description = "ID of the security group for the ALB"
  value       = aws_security_group.alb.id
}

output "instance_security_group_id" {
  description = "ID of the security group for the EC2 instances"
  value       = aws_security_group.instances.id
}