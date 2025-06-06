provider "aws" {
  region = "ap-south-1"
}


terraform {
  backend "s3" {
    bucket       = "usecases-terraform-state-bucket"
    key          = "usecase1/statefile.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}

########################
# 1. VPC + Networking
########################

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags                 = { Name = "main-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "main-igw" }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public[0].id
  tags          = { Name = "main-natgw" }
}

locals {
  azs = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}

resource "aws_subnet" "public" {
  count                   = 3
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet("10.0.0.0/16", 8, 10+count.index)
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true
  tags                    = { Name = "public-subnet-${count.index + 1}" }
}

resource "aws_subnet" "private" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet("10.0.0.0/16", 8, 20+count.index)
  availability_zone = local.azs[count.index]
  tags              = { Name = "private-subnet-${count.index + 1}" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "public-rt" }
}

resource "aws_route_table_association" "public_assoc" {
  count          = 3
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }
  tags = { Name = "private-rt" }
}

resource "aws_route_table_association" "private_assoc" {
  count          = 3
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

########################
# 2. Security Groups
########################

resource "aws_security_group" "alb_sg" {
  name   = "alb-sg"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ec2_sg" {
  name   = "ec2-sg"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

########################
# 3. ALB + Target Groups
########################

resource "aws_lb" "alb" {
  name               = "nginx-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public[*].id
}

resource "aws_lb_target_group" "tg" {
  for_each = {
    home     = { path = "/", port = 80 },
    images   = { path = "/images", port = 80 },
    register = { path = "/register", port = 80 }
  }

  name     = "${each.key}-tg"
  port     = each.value.port
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path     = "${each.value.path}/index.html"
    protocol = "HTTP"
  }

}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg["home"].arn
  }
}


resource "aws_lb_listener_rule" "routes" {
  for_each = {
    images   = { path = "/images", priority = 10 }
    register = { path = "/register", priority = 20 }
  }

  listener_arn = aws_lb_listener.http.arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg[each.key].arn
  }

  condition {
    path_pattern {
      values = [each.value.path]
    }
  }
}


########################
# 4. EC2 + Nginx Install
########################

resource "aws_instance" "nginx" {
  count                  = 3
  ami                    = "ami-0af9569868786b23a" # Amazon Linux 2
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private[count.index].id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name = "test-key"

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx
              systemctl start nginx
              systemctl enable nginx

              echo "<h1>Home Page!</h1><p>(Instance A)</p>" > /usr/share/nginx/html/index.html

              mkdir -p /usr/share/nginx/html/images
              echo "<h1>Images!</h1><p>(Instance B)</p>" > /usr/share/nginx/html/images/index.html

              mkdir -p /usr/share/nginx/html/register
              echo "<h1>Register!</h1><p>(Instance C)</p>" > /usr/share/nginx/html/register/index.html
              EOF


  tags = { Name = "nginx-${count.index + 1}" }
}

resource "aws_lb_target_group_attachment" "attach" {
  count = 3

  target_group_arn = element([
    aws_lb_target_group.tg["home"].arn,
    aws_lb_target_group.tg["images"].arn,
    aws_lb_target_group.tg["register"].arn
  ], count.index)

  target_id = aws_instance.nginx[count.index].id
  port      = 80
}

output "alb_dns_name" {
  value       = aws_lb.alb.dns_name
  description = "DNS name of the Application Load Balancer"

}
