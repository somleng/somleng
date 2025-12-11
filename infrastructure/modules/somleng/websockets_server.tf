# Security Group

resource "aws_security_group" "ws" {
  name   = "${var.app_identifier}-ws"
  vpc_id = var.region.vpc.vpc_id
}

resource "aws_security_group_rule" "ws_ingress" {
  type              = "ingress"
  to_port           = var.ws_port
  protocol          = "TCP"
  from_port         = var.ws_port
  security_group_id = aws_security_group.ws.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ws_egress" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  security_group_id = aws_security_group.ws.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# ECS

resource "aws_ecs_task_definition" "ws" {
  family                   = "${var.app_identifier}-ws"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  container_definitions = jsonencode(
    [
      {
        name  = "ws",
        image = "${var.ws_image}",
        logConfiguration = {
          logDriver = "awslogs",
          options = {
            awslogs-group         = aws_cloudwatch_log_group.app.name,
            awslogs-region        = var.region.aws_region,
            awslogs-stream-prefix = "${var.app_identifier}/${var.app_environment}"
          }
        },
        startTimeout = 120,
        essential    = true,
        healthCheck = {
          command  = ["CMD-SHELL", "wget --server-response --spider --quiet http://localhost:$ANYCABLE_PORT$ANYCABLE_HEALTH_PATH 2>&1 | grep '200 OK' > /dev/null"],
          interval = 10,
          retries  = 10,
          timeout  = 5
        },
        portMappings = [
          {
            containerPort = var.ws_port
          }
        ],
        environment = [
          {
            name  = "REDIS_URL",
            value = local.redis_url
          },
          {
            name  = "ANYCABLE_REDIS_TLS_VERIFY",
            value = "true"
          },
          {
            name  = "ANYCABLE_RPC_HOST",
            value = "${aws_route53_record.anycable.fqdn}:${var.region.internal_load_balancer.https_listener.port}",
          },
          {
            name  = "ANYCABLE_BROADCAST_ADAPTER",
            value = "redisx",
          },
          {
            name  = "ANYCABLE_BROKER",
            value = "memory",
          },
          {
            name  = "ANYCABLE_PUBSUB",
            value = "redis",
          },
          {
            name  = "ANYCABLE_HEADERS",
            value = "x-device-key",
          },
          {
            name  = "ANYCABLE_DEBUG",
            value = "1",
          },
          {
            name  = "ANYCABLE_HEALTH_PATH",
            value = var.ws_healthcheck_path,
          },
          {
            name  = "ANYCABLE_PATH",
            value = var.ws_path,
          },
          {
            name  = "ANYCABLE_HOST",
            value = "0.0.0.0",
          },
          {
            name  = "ANYCABLE_PORT",
            value = tostring(var.ws_port),
          },
          {
            name  = "ANYCABLE_DISABLE_TELEMETRY",
            value = "true",
          },
          {
            name  = "ANYCABLE_REDIS_CHANNEL",
            value = "__anycable__",
          },
          {
            name  = "ANYCABLE_LOG_FORMAT",
            value = "json",
          },
          {
            name  = "ANYCABLE_LOG_LEVEL",
            value = "debug"
          },
          {
            name  = "ANYCABLE_RPC_ENABLE_TLS",
            value = "true"
          },
        ]
        secrets = [
          {
            name      = "ANYCABLE_SECRET"
            valueFrom = aws_ssm_parameter.anycable_secret.arn
          }
        ]
      }
    ]
  )

  task_role_arn      = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.task_execution_role.arn
  memory             = module.container_instances.ec2_instance_type.memory_size - 768
}

resource "aws_ecs_service" "ws" {
  name            = aws_ecs_task_definition.ws.family
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.ws.arn
  desired_count   = var.ws_min_tasks

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.this.name
    weight            = 1
  }

  placement_constraints {
    type = "distinctInstance"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ws.arn
    container_name   = "ws"
    container_port   = var.ws_port
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ws_internal.arn
    container_name   = "ws"
    container_port   = var.ws_port
  }

  network_configuration {
    subnets = var.region.vpc.private_subnets
    security_groups = [
      aws_security_group.ws.id,
      var.db_security_group,
      aws_security_group.redis.id
    ]
  }

  depends_on = [
    aws_iam_role.task_execution_role
  ]

  lifecycle {
    ignore_changes = [task_definition]
  }
}

# Target Group

resource "aws_lb_target_group" "ws" {
  name                 = "${var.app_identifier}-ws"
  port                 = var.ws_port
  protocol             = "HTTP"
  vpc_id               = var.region.vpc.vpc_id
  target_type          = "ip"
  deregistration_delay = 60

  health_check {
    protocol          = "HTTP"
    path              = var.ws_healthcheck_path
    healthy_threshold = 3
    interval          = 10
  }
}

resource "aws_lb_target_group" "ws_internal" {
  name                 = "${var.app_identifier}-ws-internal"
  port                 = var.ws_port
  protocol             = "HTTP"
  vpc_id               = var.region.vpc.vpc_id
  target_type          = "ip"
  deregistration_delay = 60

  health_check {
    protocol          = "HTTP"
    path              = var.ws_healthcheck_path
    healthy_threshold = 3
    interval          = 10
  }
}

# Load Balancer Rule

resource "aws_lb_listener_rule" "ws" {
  priority = var.app_environment == "production" ? 12 : 112

  listener_arn = var.region.public_load_balancer.https_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ws.id
  }

  condition {
    host_header {
      values = [
        aws_route53_record.app.fqdn
      ]
    }
  }

  condition {
    path_pattern {
      values = [
        var.ws_path
      ]
    }
  }
}

resource "aws_lb_listener_rule" "ws-internal" {
  priority = var.app_environment == "production" ? 12 : 112

  listener_arn = var.region.internal_load_balancer.https_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ws_internal.id
  }

  condition {
    host_header {
      values = [
        aws_route53_record.app.fqdn
      ]
    }
  }

  condition {
    path_pattern {
      values = [
        var.ws_path
      ]
    }
  }
}

# Autoscaling

resource "aws_appautoscaling_policy" "ws_cpu_utilization" {
  name               = "${var.app_identifier}-ws"
  service_namespace  = aws_appautoscaling_target.ws_scale_target.service_namespace
  resource_id        = aws_appautoscaling_target.ws_scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ws_scale_target.scalable_dimension
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

resource "aws_appautoscaling_target" "ws_scale_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.ws.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  max_capacity       = var.ws_max_tasks
  min_capacity       = var.ws_min_tasks
}
