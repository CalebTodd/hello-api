locals {
  name_prefix = "${var.namespace}-${var.app_name}"
}

data "aws_subnet_ids" "private" {
  vpc_id = var.vpc_id

  tags = {
    type = "private"
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = var.vpc_id

  tags = {
    type = "public"
  }
}

// EC2 Security Groups

resource "aws_security_group" "main" {
  name        = "${local.name_prefix}-main"
  description = "Security Group to be used by the Fargate main"
  vpc_id      = var.vpc_id
  tags        = var.tags_common
}

resource "aws_security_group_rule" "main_ingress_self" {
  description       = "Ingress to self"
  security_group_id = aws_security_group.main.id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  self              = true
}

resource "aws_security_group_rule" "main_ingress_from_alb" {
  description              = "HTTP endpoint"
  security_group_id        = aws_security_group.main.id
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = -1
  source_security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "main_egress_all" {
  description       = "Egress to any routable network"
  security_group_id = aws_security_group.main.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

// ECS

resource "aws_ecs_task_definition" "task_definition" {
  container_definitions    = var.container_definitions
  family                   = local.name_prefix
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.ecs_task.arn
  execution_role_arn       = aws_iam_role.ecs_exec.arn
  cpu                      = 1024
  memory                   = 2048

  tags = var.tags_common
}

resource "aws_ecs_cluster" "main" {
  name = local.name_prefix
  tags = var.tags_common
}

resource "aws_ecs_service" "main" {
  name                               = local.name_prefix
  task_definition                    = join("", aws_ecs_task_definition.task_definition.*.family)
  cluster                            = aws_ecs_cluster.main.id
  desired_count                      = 1
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  launch_type                        = "FARGATE"
  platform_version                   = "1.4.0"
  scheduling_strategy                = "REPLICA"
  enable_ecs_managed_tags            = false
  tags                               = var.tags_common

  network_configuration {
    assign_public_ip = false
    subnets          = data.aws_subnet_ids.private.ids
    security_groups  = [aws_security_group.main.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.default.arn
    container_name   = var.app_name
    container_port   = var.app_port
  }
}
