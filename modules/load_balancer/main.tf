# Load Balancer Module - Creates the ALB, target groups, and listener rules

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "path-routing-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnets

  enable_deletion_protection = false

  tags = merge(
    var.project_tags,
    {
      Name = "path-based-routing-alb"
    }
  )
}

# Target Groups
resource "aws_lb_target_group" "target_groups" {
  for_each = var.target_groups

  name     = "${each.value.name}-tg"
  port     = each.value.port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    matcher             = "200-399"
  }

  tags = merge(
    var.project_tags,
    {
      Name = "${each.value.name}-target-group"
    }
  )
}

# Default Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_groups["homepage"].arn
  }
}

# Listener Rules for path-based routing
resource "aws_lb_listener_rule" "path_based_rules" {
  for_each = { for k, v in var.target_groups : k => v if k != "homepage" }

  listener_arn = aws_lb_listener.http.arn
  priority     = 100 + index(keys({ for k, v in var.target_groups : k => v if k != "homepage" }), each.key)

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_groups[each.key].arn
  }

  condition {
    path_pattern {
      values = [each.value.path]
    }
  }
}