# ECS Container Instance Role

data "aws_iam_policy_document" "ecs_container_instance_trust_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ecs_container_instance_role" {
  name = "${var.app_identifier}-ecsContainerInstanceRole"

  assume_role_policy = data.aws_iam_policy_document.ecs_container_instance_trust_policy.json
}

resource "aws_iam_instance_profile" "ecs_container_instance_profile" {
  name = "${var.app_identifier}-ecsContainerInstanceProfile"
  role = aws_iam_role.ecs_container_instance_role.name
}

resource "aws_iam_role_policy_attachment" "ecs_container_instance_task_execution" {
  role       = aws_iam_role.ecs_container_instance_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_container_instance_ec2" {
  role       = aws_iam_role.ecs_container_instance_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_container_instance_ssm" {
  role       = aws_iam_role.ecs_container_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Security Groups

resource "aws_security_group" "container_instance" {
  name   = "${var.app_identifier}-container-instance"
  vpc_id = var.region.vpc.vpc_id
}

resource "aws_security_group_rule" "container_instance_egress" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  security_group_id = aws_security_group.container_instance.id
  cidr_blocks       = ["0.0.0.0/0"]
}
