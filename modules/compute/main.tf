# Compute Module - Creates EC2 instances and registers them with target groups

# Latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# EC2 Instances
resource "aws_instance" "app_instances" {
  for_each = var.instances
  
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = var.private_subnets[each.value.subnet_index % length(var.private_subnets)]
  vpc_security_group_ids = [var.instance_security_group]
  user_data              = each.value.user_data
  
  tags = merge(
    var.project_tags,
    {
      Name = each.value.name
    }
  )
}

# Target Group Attachments
resource "aws_lb_target_group_attachment" "homepage" {
  target_group_arn = var.target_group_arns["homepage"]
  target_id        = aws_instance.app_instances["homepage"].id
  port             = 80
}

resource "aws_lb_target_group_attachment" "images" {
  target_group_arn = var.target_group_arns["images"]
  target_id        = aws_instance.app_instances["images"].id
  port             = 80
}

resource "aws_lb_target_group_attachment" "register" {
  target_group_arn = var.target_group_arns["register"]
  target_id        = aws_instance.app_instances["register"].id
  port             = 80
}
