# Outputs from the Load Balancer module

output "alb_dns_name" {
  description = "DNS name of the application load balancer"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN of the application load balancer"
  value       = aws_lb.main.arn
}

output "target_group_arns" {
  description = "ARNs of the target groups"
  value       = { for k, v in aws_lb_target_group.target_groups : k => v.arn }
}