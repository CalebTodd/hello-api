// Security - IAM
data "aws_iam_policy_document" "ecs_task" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task" {
  name               = "${local.name_prefix}-ecs_task"
  assume_role_policy = join("", data.aws_iam_policy_document.ecs_task.*.json)
  tags               = var.tags_common
}

data "aws_iam_policy_document" "ecs_task_policy" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:DescribeImageScanFindings",
      "ecr:DescribeRepositories",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetLifecyclePolicy",
      "ecr:GetLifecyclePolicyPreview",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "ecr:ListTagsForResource"
    ]
  }
}

resource "aws_iam_role_policy" "ecs_task" {
  name   = "${local.name_prefix}-ecs_task"
  policy = join("", data.aws_iam_policy_document.ecs_task_policy.*.json)
  role   = join("", aws_iam_role.ecs_task.*.id)
}

# IAM role that the Amazon ECS container agent and the Docker daemon can assume
data "aws_iam_policy_document" "ecs_task_exec" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_exec" {
  name               = "${local.name_prefix}-ecs_exec"
  assume_role_policy = join("", data.aws_iam_policy_document.ecs_task_exec.*.json)
  tags               = var.tags_common
}

data "aws_iam_policy_document" "ecs_exec" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ssm:GetParameters",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
  }
}

resource "aws_iam_role_policy" "ecs_exec" {
  name   = "${local.name_prefix}-ecs_exec"
  policy = join("", data.aws_iam_policy_document.ecs_exec.*.json)
  role   = join("", aws_iam_role.ecs_exec.*.id)
}
