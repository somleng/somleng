# Security Groups

resource "aws_security_group" "anycable" {
  name   = "${var.app_identifier}-anycable"
  vpc_id = var.region.vpc.vpc_id
}

resource "aws_security_group_rule" "anycable_ingress" {
  type              = "ingress"
  to_port           = var.anycable_rpc_port
  protocol          = "TCP"
  from_port         = var.anycable_rpc_port
  security_group_id = aws_security_group.anycable.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "anycable_egress" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  security_group_id = aws_security_group.anycable.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# ECS

resource "aws_ecs_task_definition" "anycable" {
  family                   = "${var.app_identifier}-anycable"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  container_definitions = jsonencode(
    [
      {
        name  = "anycable",
        image = "${var.app_image}:latest",
        logConfiguration = {
          logDriver = "awslogs",
          options = {
            awslogs-group         = aws_cloudwatch_log_group.app.name,
            awslogs-region        = var.region.aws_region,
            awslogs-stream-prefix = "${var.app_identifier}/${var.app_environment}"
          }
        },
        command      = ["bundle", "exec", "anycable"],
        startTimeout = 120,
        essential    = true,
        healthCheck = {
          command  = ["CMD-SHELL", "grpc-health-probe -addr :$ANYCABLE_RPC_PORT"],
          interval = 10,
          retries  = 10,
          timeout  = 5
        },
        portMappings = [
          {
            containerPort = var.anycable_rpc_port
          }
        ],
        environment = concat(
          local.shared_container_environment,
          [
            {
              name  = "ANYCABLE_RPC_HOST",
              value = "0.0.0.0:${var.anycable_rpc_port}"
            },
            {
              name  = "ANYCABLE_RPC_PORT",
              value = tostring(var.anycable_rpc_port)
            },
            {
              name  = "ANYCABLE_LOG_LEVEL",
              value = "debug"
            },
            {
              name  = "ANYCABLE_DEBUG",
              value = "1"
            }
          ]
        )
        secrets = concat(
          local.shared_container_secrets,
          [
            {
              name      = "ANYCABLE_SECRET"
              valueFrom = aws_ssm_parameter.anycable_secret.arn
            }
          ]
        )
      }
    ]
  )

  task_role_arn      = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.task_execution_role.arn
  memory             = module.container_instances.ec2_instance_type.memory_size - 768
}

resource "aws_ecs_service" "anycable" {
  name            = aws_ecs_task_definition.anycable.family
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.anycable.arn
  desired_count   = var.anycable_min_tasks

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.this.name
    weight            = 1
  }

  placement_constraints {
    type = "distinctInstance"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.anycable.arn
    container_name   = "anycable"
    container_port   = var.anycable_rpc_port
  }

  network_configuration {
    subnets = var.region.vpc.private_subnets
    security_groups = [
      aws_security_group.anycable.id,
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

resource "aws_lb_target_group" "anycable" {
  name                 = "${var.app_identifier}-anycable"
  port                 = var.anycable_rpc_port
  protocol             = "HTTP"
  protocol_version     = "GRPC"
  vpc_id               = var.region.vpc.vpc_id
  target_type          = "ip"
  deregistration_delay = 60

  health_check {
    path              = "/grpc.health.v1.Health/Check"
    healthy_threshold = 3
    interval          = 10
    matcher           = "0"
  }
}

# Route53

resource "aws_route53_record" "anycable" {
  zone_id = var.internal_route53_zone.zone_id
  name    = var.anycable_subdomain
  type    = "A"

  alias {
    name                   = var.region.internal_load_balancer.this.dns_name
    zone_id                = var.region.internal_load_balancer.this.zone_id
    evaluate_target_health = true
  }
}

# Load Balancer

resource "aws_lb_listener_rule" "anycable" {
  priority = var.app_environment == "production" ? 10 : 110

  listener_arn = var.region.internal_load_balancer.https_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.anycable.id
  }

  condition {
    host_header {
      values = [
        aws_route53_record.anycable.fqdn
      ]
    }
  }
}

# Autoscaling

resource "aws_appautoscaling_policy" "anycable_cpu_utilization" {
  name               = "${var.app_identifier}-anycable"
  service_namespace  = aws_appautoscaling_target.anycable_scale_target.service_namespace
  resource_id        = aws_appautoscaling_target.anycable_scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.anycable_scale_target.scalable_dimension
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

resource "aws_appautoscaling_target" "anycable_scale_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.anycable.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  max_capacity       = var.anycable_max_tasks
  min_capacity       = var.anycable_min_tasks
}
