# AWS Infrastructure with Application Load Balancer and Path-Based Routing

This document explains the infrastructure components and their purposes in our AWS setup.

## Core Components

### VPC Module (`modules/vpc`)
- Creates an isolated network environment
- Components:
  - Custom VPC with CIDR block 10.0.0.0/16
  - Public subnets for internet-facing resources (ALB)
  - Private subnets for EC2 instances
  - Internet Gateway for public internet access
  - NAT Gateway for private subnet internet access
  - Route tables for traffic management

**Why?** Provides network isolation and security, enabling proper segmentation of public and private resources.

### Security Module (`modules/security`)
- Manages security groups for ALB and EC2 instances
- Components:
  - ALB Security Group:
    - Allows inbound HTTP (80) and HTTPS (443)
    - Permits outbound traffic to EC2 instances
  - EC2 Security Group:
    - Allows inbound traffic only from ALB
    - Permits all outbound traffic

**Why?** Implements defense in depth by controlling traffic flow and limiting attack surface.

### Load Balancer Module (`modules/load_balancer`)
- Manages the Application Load Balancer setup
- Components:
  - Application Load Balancer (ALB)
  - Target Groups for each path:
    - Homepage (/)
    - Images (/images)
    - Register (/register)
  - Listener Rules for path-based routing

**Why?** Enables:
- High availability through multiple AZs
- Path-based routing to different backend services
- Health checks and automatic failover
- SSL/TLS termination (if configured)

### Compute Module (`modules/compute`)
- Manages EC2 instances and their configuration
- Components:
  - Three EC2 instances (t2.micro):
    1. Homepage Instance:
       - Serves root path (/)
       - Basic welcome page
    2. Images Instance:
       - Serves /images path
       - Image gallery functionality
    3. Register Instance:
       - Serves /register path
       - Registration form functionality
  - Target Group attachments
  - User data scripts for instance configuration

**Why?** Provides:
- Segregated services for different functionalities
- Independent scaling capabilities
- Isolated maintenance and updates

## Infrastructure Flow

1. User Request → ALB (Public Subnet)
2. ALB evaluates path and routes to appropriate target group
3. Request forwarded to EC2 instance (Private Subnet)
4. Response returns through ALB to user

## State Management

- Backend: S3 bucket with locking
- Components:
  - S3 bucket: `terraform-state-alb-routing`

**Why?** Enables:
- Team collaboration
- State locking to prevent conflicts
- State versioning and backup
- Secure state storage

## Network Architecture

```
                                     │
                                     ▼
                                 Internet
                                     │
                                     ▼
                            Internet Gateway
                                     │
                                     ▼
                     ┌───────────────────────────┐
                     │   Application Load        │
                     │   Balancer (Public)       │
                     └───────────────────────────┘
                                     │
                     ┌──────────────┴──────────────┐
                     ▼                             ▼
             Homepage Instance            Images Instance
             (Private Subnet)           (Private Subnet)
                     │                             │
                     └──────────────┬──────────────┘
                                   ▼
                          Register Instance
                          (Private Subnet)
```

## Security Considerations

1. **Network Segmentation**
   - Public subnets only contain the ALB
   - EC2 instances in private subnets
   - NAT Gateway for outbound internet access

2. **Access Control**
   - Security groups limit traffic flow
   - No direct internet access to instances
   - All traffic flows through ALB

3. **Updates and Maintenance**
   - Instances can access internet for updates via NAT
   - Independent maintenance windows possible
   - Rolling updates supported

## Scaling Considerations

- ALB supports auto scaling groups (if implemented)
- Multiple AZs for high availability
- Independent scaling per service path
- Health checks for automatic failover
