# AWS Infrastructure with ALB and Path-Based Routing

This Terraform project sets up a complete AWS infrastructure with path-based routing using an Application Load Balancer.

## Architecture

The infrastructure includes:

- Custom VPC with public and private subnets across three availability zones
- Internet Gateway and NAT Gateway for internet connectivity
- Application Load Balancer with path-based routing
- Three EC2 instances in private subnets, each serving different content:
  - Instance A: Responds to the root path (/)
  - Instance B: Responds to the /images path
  - Instance C: Responds to the /register path

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (>= 1.2.0)
- AWS CLI configured with appropriate credentials
- Node.js (for npm scripts)

## Usage

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Preview the changes:
   ```bash
   npm run plan
   ```

3. Apply the configuration:
   ```bash
   npm run apply
   ```

4. Access the application:
   After successful deployment, you'll get the ALB DNS name in the outputs. Use this URL to access:
   - Homepage: http://<alb_dns_name>/
   - Images: http://<alb_dns_name>/images
   - Registration: http://<alb_dns_name>/register

5. To destroy the infrastructure:
   ```bash
   npm run destroy
   ```

## Structure

- `main.tf` - Main configuration file
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `modules/` - Modular components:
  - `vpc/` - VPC and networking resources
  - `security/` - Security groups
  - `load_balancer/` - ALB and listener rules
  - `compute/` - EC2 instances and target group attachments
- `scripts/` - User data scripts for EC2 instances

## Notes

- Each EC2 instance runs Nginx and serves custom HTML content
- Instances are placed in private subnets for enhanced security
- All traffic to the instances is routed through the ALB