# Security Groups

resource "aws_security_group" "appserver" {
  name   = "${var.app_identifier}-appserver"
  vpc_id = var.vpc.vpc_id
}

resource "aws_security_group_rule" "appserver_ingress" {
  type              = "ingress"
  to_port           = 80
  protocol          = "TCP"
  from_port         = 80
  security_group_id = aws_security_group.appserver.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "appserver_egress" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  security_group_id = aws_security_group.appserver.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# Cloudwatch

resource "aws_cloudwatch_log_group" "nginx" {
  name              = "${var.app_identifier}-nginx"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "appserver" {
  name              = "${var.app_identifier}-appserver"
  retention_in_days = 7
}

# ECS

resource "aws_ecs_task_definition" "appserver" {
  family                   = "${var.app_identifier}-appserver"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  container_definitions = jsonencode([
    {
      name  = "nginx"
      image = "${var.nginx_image}:latest"
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.nginx.name,
          awslogs-region        = var.aws_region,
          awslogs-stream-prefix = var.app_environment
        }
      },
      essential = true,
      portMappings = [
        {
          containerPort = 80
        }
      ],
      dependsOn = [
        {
          containerName = "app",
          condition     = "HEALTHY"
        }
      ]
    },
    {
      name  = "app",
      image = "${var.app_image}:latest",
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.appserver.name,
          awslogs-region        = var.aws_region,
          awslogs-stream-prefix = var.app_environment
        }
      },
      startTimeout = 120,
      healthCheck  = local.shared_container_healthcheck,
      essential    = true,
      portMappings = [
        {
          containerPort = 3000
        }
      ],
      secrets     = local.shared_container_secrets,
      environment = local.shared_container_environment
    }
  ])

  task_role_arn      = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.task_execution_role.arn
  memory             = module.container_instances.ec2_instance_type.memory_size - 768
}

resource "aws_ecs_service" "appserver" {
  name            = aws_ecs_task_definition.appserver.family
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.appserver.arn
  desired_count   = var.appserver_min_tasks

  network_configuration {
    subnets = var.vpc.private_subnets
    security_groups = [
      aws_security_group.appserver.id,
      var.db_security_group,
      var.redis_security_group
    ]
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.this.name
    weight            = 1
  }

  placement_constraints {
    type = "distinctInstance"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.webserver.arn
    container_name   = "nginx"
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [load_balancer, task_definition]
  }

  depends_on = [
    aws_iam_role.task_execution_role
  ]
}

# Target group

resource "aws_lb_target_group" "webserver" {
  name                 = var.app_identifier
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = var.vpc.vpc_id
  target_type          = "ip"
  deregistration_delay = 60

  health_check {
    protocol          = "HTTP"
    path              = "/health_checks"
    healthy_threshold = 3
    interval          = 10
  }
}

resource "aws_lb_listener_rule" "webserver" {
  priority = var.app_environment == "production" ? 15 : 115

  listener_arn = var.listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webserver.id
  }

  condition {
    host_header {
      values = [
        aws_route53_record.api.fqdn,
        aws_route53_record.verify.fqdn,
        aws_route53_record.app.fqdn,
        "*.${aws_route53_record.app.fqdn}"
      ]
    }
  }
}

# Autoscaling

resource "aws_appautoscaling_policy" "appserver_cpu_utilization" {
  name               = var.app_identifier
  service_namespace  = aws_appautoscaling_target.appserver_scale_target.service_namespace
  resource_id        = aws_appautoscaling_target.appserver_scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.appserver_scale_target.scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 50
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_target" "appserver_scale_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.appserver.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  max_capacity       = var.appserver_max_tasks
  min_capacity       = var.appserver_min_tasks
}
