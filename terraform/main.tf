locals {
  name_prefix = "${var.namespace}-${var.app_name}"
}

data "aws_region" "current_region" {}

module vpc {
  source      = "./modules/vpc"
  namespace   = var.namespace
  vpc_cidr    = var.vpc_cidr
  tags_common = var.tags_common
}

module subnets {
  source              = "./modules/subnets"
  namespace           = var.namespace
  tags_common         = var.tags_common
  vpc_id              = module.vpc.vpc_id
  igw_id              = module.vpc.igw_id
  availability_zones  = var.availability_zones
  cidr_offset_public  = 0
  cidr_offset_private = length(var.availability_zones) + 1
}

// Fargate things

module app {
  source                = "./modules/fargate"
  namespace             = var.namespace
  app_name              = var.app_name
  tags_common           = var.tags_common
  vpc_id                = module.vpc.vpc_id
  container_definitions = data.template_file.task_def_app.rendered
  app_port              = var.app_port
  efs_sourceVolume      = "database_postgres"
}

data "template_file" "task_def_app" {
  template = file("${path.module}/templates/ecs_task_definitions/${var.app_name}.json")

  vars = {
    app_name = var.app_name
    # repository-url/image:tag
    container_image = "${aws_ecr_repository.app.repository_url}:${var.image_tag}"
    app_log_group   = aws_cloudwatch_log_group.app.name
    db_log_group    = aws_cloudwatch_log_group.db.name
    log_region      = data.aws_region.current_region.name
    db_password     = aws_ssm_parameter.db_password.name
    db_user         = var.db_user
    db_name         = var.db_name
    db_host         = var.db_host
    app_port        = var.app_port
  }
}

resource "aws_ssm_parameter" "db_password" {
  name      = "/${var.namespace}/${var.app_name}/db/db_password"
  type      = "SecureString"
  value     = var.db_password
  overwrite = true
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "${local.name_prefix}-app"
  tags              = var.tags_common
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "db" {
  name              = "${local.name_prefix}-db"
  tags              = var.tags_common
  retention_in_days = 7
}

// ECR repository
resource "aws_ecr_repository" "app" {
  name                 = "${var.namespace}/${var.app_name}"
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.tags_common
}

resource "aws_ecr_repository_policy" "app" {
  repository = aws_ecr_repository.app.name
  policy     = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "adds full ecr access",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
      }
    ]
  }
  EOF
}
