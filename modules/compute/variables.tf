# Variables for the Compute module

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnets" {
  description = "IDs of the private subnets"
  type        = list(string)
}

variable "instance_security_group" {
  description = "ID of the security group for the EC2 instances"
  type        = string
}

variable "target_group_arns" {
  description = "ARNs of the target groups"
  type        = map(string)
}

variable "instances" {
  description = "Map of instance configurations"
  type        = map(object({
    name         = string
    subnet_index = number
    user_data    = string
  }))
}

variable "project_tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}