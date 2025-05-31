# Variables for the Security module

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "project_tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}