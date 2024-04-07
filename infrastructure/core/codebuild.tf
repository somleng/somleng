locals {
  codebuild_identifier = "somleng"
}

data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codebuild" {
  name               = "codebuild-${local.codebuild_identifier}"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
}

data "aws_iam_policy_document" "codebuild" {
  statement {
    effect = "Allow"

    resources = [
      "arn:aws:logs:*:*:log-group:/aws/codebuild/${local.codebuild_identifier}*",
      "arn:aws:logs:*:*:log-group:/aws/codebuild/${local.codebuild_identifier}*:*"
    ]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
  }
}

resource "aws_iam_role_policy" "codebuild" {
  role   = aws_iam_role.codebuild.name
  policy = data.aws_iam_policy_document.codebuild.json
}

resource "aws_iam_role_policy_attachment" "codebuild_ecr_public" {
  role       = aws_iam_role.codebuild.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicPowerUser"
}

resource "aws_iam_role_policy_attachment" "codebuild_ecr" {
  role       = aws_iam_role.codebuild.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_codebuild_project" "amd64" {
  name = "${local.codebuild_identifier}-amd64"

  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  environment {
    compute_type    = "BUILD_GENERAL1_LARGE"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }

  source {
    type     = "GITHUB"
    location = "https://github.com/somleng/somleng.git"
  }
}

resource "aws_codebuild_project" "arm64" {
  name = "${local.codebuild_identifier}-arm64"

  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  environment {
    compute_type    = "BUILD_GENERAL1_LARGE"
    image           = "aws/codebuild/amazonlinux2-aarch64-standard:3.0"
    type            = "ARM_CONTAINER"
    privileged_mode = true
  }

  source {
    type     = "GITHUB"
    location = "https://github.com/somleng/somleng.git"
  }
}
