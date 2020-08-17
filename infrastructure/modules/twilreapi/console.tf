resource "tls_private_key" "console" {
  algorithm   = "RSA"
  rsa_bits = "2048"
}

resource "local_file" "console_key_pair" {
  sensitive_content = tls_private_key.console.private_key_pem
  filename = pathexpand("~/.ssh/${var.app_identifier}-console")
  file_permission = "600"
}

resource "aws_key_pair" "console" {
  key_name   = "${var.app_identifier}-console"
  public_key = tls_private_key.console.public_key_openssh
}

resource "aws_iam_role" "console" {
  name = "${var.app_identifier}_ecs_instance_role"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "console" {
  name = "${var.app_identifier}_ecs_instance_profile"
  role = aws_iam_role.console.name
}

resource "aws_iam_role_policy_attachment" "console_ecs" {
  role = aws_iam_role.console.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
resource "aws_iam_role_policy_attachment" "console_ecs_ec2_role" {
  role = aws_iam_role.console.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}
resource "aws_iam_role_policy_attachment" "console_ssm" {
  role       = aws_iam_role.console.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

data "aws_ecs_task_definition" "console" {
  task_definition = aws_ecs_task_definition.worker.family
}

data "aws_ssm_parameter" "console" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended"
}

resource "aws_ecs_service" "console" {
  name = "${var.app_identifier}-console"
  cluster = var.ecs_cluster.name
  task_definition = data.aws_ecs_task_definition.console.id
  launch_type = "EC2"

  desired_count = 0
  deployment_maximum_percent = 100
  deployment_minimum_healthy_percent = 0

  network_configuration {
    subnets = var.container_instance_subnets
    security_groups = [aws_security_group.worker.id, var.db_security_group]
  }
}

resource "aws_launch_configuration" "console" {
  image_id                    = jsondecode(data.aws_ssm_parameter.console.value).image_id
  instance_type               = "t3.small"
  iam_instance_profile        = aws_iam_instance_profile.console.name
  security_groups             = [aws_security_group.worker.id, var.db_security_group]
  user_data                   = data.template_file.console_user_data.rendered
  key_name = aws_key_pair.console.key_name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "console" {
  name                 = "${var.app_identifier}-console"
  launch_configuration = aws_launch_configuration.console.name
  vpc_zone_identifier  = var.container_instance_subnets
  max_size             = 1
  min_size             = 0
  desired_capacity     = 0
  wait_for_capacity_timeout = 0

  tag {
    key                 = "Name"
    value               = "${var.app_identifier}-console"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_schedule" "console_shutdown" {
  scheduled_action_name  = "${var.app_identifier}-console-shutdown"
  autoscaling_group_name = aws_autoscaling_group.console.name
  recurrence = "0 13 * * *"
  desired_capacity = 0
  max_size = 1
}

data "template_file" "console_user_data" {
  template = file("${path.module}/templates/console_user_data.sh")

  vars = {
    cluster_name = var.ecs_cluster.name
  }
}
