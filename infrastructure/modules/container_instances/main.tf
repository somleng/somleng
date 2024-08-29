# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/retrieve-ecs-optimized_AMI.html
data "aws_ssm_parameter" "this_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/arm64/recommended"
}

data "aws_ec2_instance_type" "this" {
  instance_type = var.instance_type
}

locals {
  user_data = concat(var.user_data, [
    {
      path = "/opt/setup.sh"
      content = templatefile(
        "${path.module}/templates/setup.sh",
        {
          cluster_name = var.cluster_name
        }
      )
      permissions = "755"
    }
  ])
}

# IAM

resource "aws_iam_role" "this" {
  name = "${var.identifier}_ecs_container_instance_role"

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

resource "aws_iam_instance_profile" "this" {
  name = "${var.identifier}_ecs_container_instance_profile"
  role = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "ecs" {
  role       = aws_iam_role.this.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_role" {
  role       = aws_iam_role.this.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Launch Template
resource "aws_launch_template" "this" {
  name_prefix   = var.identifier
  image_id      = jsondecode(data.aws_ssm_parameter.this_ami.value).image_id
  instance_type = data.aws_ec2_instance_type.this.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.this.name
  }

  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_address
    security_groups             = concat([aws_security_group.this.id], var.security_groups)
  }

  user_data = base64encode(join("\n", [
    "#cloud-config",
    yamlencode({
      # https://cloudinit.readthedocs.io/en/latest/topics/modules.html
      write_files : local.user_data,
      runcmd : [for i, v in local.user_data : v.path]
    })
  ]))

  lifecycle {
    create_before_destroy = true
  }
}

# Security Group

resource "aws_security_group" "this" {
  name   = "${var.identifier}-container-instance"
  vpc_id = var.vpc.vpc_id
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  security_group_id = aws_security_group.this.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# Autoscaling Group

resource "aws_autoscaling_group" "this" {
  name = var.identifier

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }

  vpc_zone_identifier       = var.instance_subnets
  max_size                  = var.max_capacity
  min_size                  = 0
  desired_capacity          = 0
  wait_for_capacity_timeout = 0
  protect_from_scale_in     = true

  tag {
    key                 = "Name"
    value               = var.identifier
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes        = [desired_capacity]
    create_before_destroy = true
  }
}

# Automatically update the SSM agent

# https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-state-cli.html
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_association
resource "aws_ssm_association" "update_ssm_agent" {
  name = "AWS-UpdateSSMAgent"

  targets {
    key    = "tag:Name"
    values = [var.identifier]
  }

  schedule_expression = "cron(0 19 ? * SAT *)"
}
