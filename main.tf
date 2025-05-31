# Main Terraform configuration file

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.region
}



module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  project_tags         = var.project_tags
}

module "security" {
  source = "./modules/security"

  vpc_id       = module.vpc.vpc_id
  project_tags = var.project_tags
}

module "load_balancer" {
  source = "./modules/load_balancer"

  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnet_ids
  alb_sg_id      = module.security.alb_security_group_id
  project_tags   = var.project_tags

  target_groups = {
    homepage = {
      name = "homepage"
      path = "/"
      port = 80
    }
    images = {
      name = "images"
      path = "/images*"
      port = 80
    }
    register = {
      name = "register"
      path = "/register*"
      port = 80
    }
  }
}

module "compute" {
  source = "./modules/compute"

  vpc_id                  = module.vpc.vpc_id
  private_subnets         = module.vpc.private_subnet_ids
  instance_security_group = module.security.instance_security_group_id
  project_tags            = var.project_tags

  target_group_arns = {
    homepage = module.load_balancer.target_group_arns["homepage"]
    images   = module.load_balancer.target_group_arns["images"]
    register = module.load_balancer.target_group_arns["register"]
  }

  instances = {
    homepage = {
      name         = "homepage-instance"
      subnet_index = 0
      user_data    = file("${path.module}/scripts/homepage_user_data.sh")
    }
    images = {
      name         = "images-instance"
      subnet_index = 1
      user_data    = file("${path.module}/scripts/images_user_data.sh")
    }
    register = {
      name         = "register-instance"
      subnet_index = 2
      user_data    = file("${path.module}/scripts/register_user_data.sh")
    }
  }
}
