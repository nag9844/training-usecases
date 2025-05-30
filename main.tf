provider "aws" {
  region = "ap-south-1"
}
 
resource "aws_vpc" "main" {
cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = { Name = "custom-vpc" }
}
 
resource "aws_internet_gateway" "gw" {
vpc_id = aws_vpc.main.id
}
 
resource "aws_subnet" "public" {
  count                   = 3
vpc_id = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = { Name = "public-subnet-${count.index + 1}" }
}
 
data "aws_availability_zones" "available" {}
 
resource "aws_route_table" "public" {
vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.gw.id
  }
}
 
resource "aws_route_table_association" "a" {
  count          = 3
  subnet_id      = aws_subnet.public[count.index].id
route_table_id = aws_route_table.public.id
}
 
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP and SSH"
vpc_id = aws_vpc.main.id
 
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  ingress {
    from_port   = 22
    to_port     = 22
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
 
resource "aws_launch_template" "web" {
  name_prefix   = "web-"
image_id = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
user_data = base64encode(file("user-data.sh"))
vpc_security_group_ids = [aws_security_group.web_sg.id]
 
  lifecycle {
    create_before_destroy = true
  }
}
 
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
 
resource "aws_instance" "web" {
  count               = 3
  ami                 = data.aws_ami.amazon_linux.id
  instance_type       = "t2.micro"
  subnet_id           = aws_subnet.public[count.index].id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  user_data           = file("userdata${count.index + 1}.sh")
  tags = {
    Name = "instance-${count.index + 1}"
  }
}
 
resource "aws_lb" "alb" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
security_groups = [aws_security_group.web_sg.id]
  subnets            = aws_subnet.public[*].id
}
 
resource "aws_lb_target_group" "tg" {
  count    = 3
  name     = "tg-${count.index + 1}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
 
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
 
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
 
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg[0].arn
  }
}

resource "aws_lb_listener_rule" "path_based" {
  count             = 2
  listener_arn      = aws_lb_listener.http.arn
  priority          = count.index + 1
 
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg[count.index + 1].arn
  }
 
  condition {
    path_pattern {
      values = [
        count.index == 0 ? "/images" : "/register"
      ]
    }
  }
}

resource "aws_lb_target_group_attachment" "attach" {
  count            = 3
target_group_arn = aws_lb_target_group.tg[count.index].arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
}