# ECS task role
data "aws_iam_policy_document" "ecs_task_assume_role_policy" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.app_identifier}-ecsTaskRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role_policy.json
}

data "aws_iam_policy_document" "ecs_task_policy" {
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.uploads.arn, data.aws_s3_bucket.raw_recordings.arn]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject", "s3:DeleteObject", "s3:GetObject"]
    resources = ["${aws_s3_bucket.uploads.arn}/*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${data.aws_s3_bucket.raw_recordings.arn}/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:ChangeMessageVisibilityBatch",
      "sqs:DeleteMessage",
      "sqs:DeleteMessageBatch",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage",
      "sqs:SendMessage",
      "sqs:SendMessageBatch"
    ]
    resources = [
      aws_sqs_queue.high_priority.arn,
      aws_sqs_queue.medium_priority.arn,
      aws_sqs_queue.default.arn,
      aws_sqs_queue.outbound_calls.arn,
      aws_sqs_queue.low_priority.arn,
      aws_sqs_queue.long_running.arn,
      aws_sqs_queue.scheduler.arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "sqs:SendMessage"
    ]
    resources = [
      data.aws_sqs_queue.call_service.arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "sqs:ListQueues"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ses:SendRawEmail"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "polly:DescribeVoices"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecs_task_policy" {
  name = "${var.app_identifier}-ecsTaskPolicy"

  policy = data.aws_iam_policy_document.ecs_task_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_policy" {
  role       = aws_iam_role.ecs_task_role.id
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}

data "aws_iam_policy_document" "assume_ecs_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "task_execution_role" {
  name               = "${var.app_identifier}-ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_ecs_role.json
}

data "aws_iam_policy_document" "task_execution_policy" {
  statement {
    effect  = "Allow"
    actions = ["ssm:GetParameters"]
    resources = [
      aws_ssm_parameter.rails_master_key.arn,
      aws_ssm_parameter.services_password.arn,
      aws_ssm_parameter.anycable_secret.arn,
      var.db_password_parameter_arn,
      data.aws_ssm_parameter.region_data.arn,
      data.aws_ssm_parameter.call_service_password.arn,
      data.aws_ssm_parameter.rating_engine_password.arn
    ]
  }
}

resource "aws_iam_policy" "task_execution_custom_policy" {
  name = "${var.app_identifier}-task-execution-custom-policy"

  policy = data.aws_iam_policy_document.task_execution_policy.json
}

resource "aws_iam_role_policy_attachment" "task_execution_role_policy" {
  role       = aws_iam_role.task_execution_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "task_execution_custom_policy" {
  role       = aws_iam_role.task_execution_role.id
  policy_arn = aws_iam_policy.task_execution_custom_policy.arn
}
