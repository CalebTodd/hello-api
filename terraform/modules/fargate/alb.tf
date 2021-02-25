// EC2 Security Groups

resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb"
  description = "Security Group to be used by the load balancer"
  vpc_id      = var.vpc_id
  tags        = var.tags_common
}

resource "aws_security_group_rule" "alb_ingress_http" {
  description       = "HTTP endpoint"
  security_group_id = aws_security_group.alb.id
  type              = "ingress"
  from_port         = var.app_port
  to_port           = var.app_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_egress_all" {
  description       = "Egress to any routable network"
  security_group_id = aws_security_group.alb.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

// ALB

resource "aws_lb" "main" {
  name               = local.name_prefix
  tags               = var.tags_common
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets                          = data.aws_subnet_ids.public.ids
  enable_cross_zone_load_balancing = true
  ip_address_type                  = "ipv4"
}

resource "aws_lb_target_group" "default" {
  name_prefix          = substr(local.name_prefix, 0, 6)
  port                 = var.app_port
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = var.vpc_id
  deregistration_delay = 10

  health_check {
    protocol            = "HTTP"
    path                = "/"
    port                = var.app_port
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 4
    interval            = 15
    matcher             = 200
  }

  tags = var.tags_common
}


resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = var.app_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.default.arn
    type             = "forward"
  }
}