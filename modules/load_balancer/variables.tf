# Variables for the Load Balancer module

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnets" {
  description = "IDs of the public subnets"
  type        = list(string)
}

variable "alb_sg_id" {
  description = "ID of the security group for the ALB"
  type        = string
}

variable "target_groups" {
  description = "Map of target groups to create"
  type = map(object({
    name = string
    path = string
    port = number
  }))
}

variable "project_tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}