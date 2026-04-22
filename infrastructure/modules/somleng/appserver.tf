# Container instances

module "appserver_container_instances" {
  source = "../container_instances"

  identifier       = "${var.app_identifier}-appserver"
  vpc              = var.region.vpc
  instance_subnets = var.region.vpc.private_subnets
  cluster_name     = aws_ecs_cluster.this.name
  max_capacity     = (var.appserver_max_tasks * 2)
  instance_type    = "t4g.medium"
}

# Security Groups

resource "aws_security_group" "appserver" {
  name   = "${var.app_identifier}-appserver"
  vpc_id = var.region.vpc.vpc_id
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
          awslogs-group         = aws_cloudwatch_log_group.app.name,
          awslogs-region        = var.region.aws_region,
          awslogs-stream-prefix = "${var.app_identifier}/${var.app_environment}"
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
          awslogs-group         = aws_cloudwatch_log_group.app.name,
          awslogs-region        = var.region.aws_region,
          awslogs-stream-prefix = "${var.app_identifier}/${var.app_environment}"
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
  memory             = module.appserver_container_instances.ec2_instance_type.memory_size - 768
}

# Capacity Provider

resource "aws_ecs_capacity_provider" "appserver_asg" {
  name = "${var.app_identifier}-appserver-asg"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = module.appserver_container_instances.autoscaling_group.arn
    managed_termination_protection = "ENABLED"
    managed_draining               = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}

resource "aws_ecs_capacity_provider" "appserver_managed" {
  name    = "${var.app_identifier}-appserver-managed"
  cluster = aws_ecs_cluster.this.name

  managed_instances_provider {
    infrastructure_role_arn = aws_iam_role.ecs_infrastructure_role.arn
    propagate_tags          = "CAPACITY_PROVIDER"

    instance_launch_template {
      ec2_instance_profile_arn = aws_iam_instance_profile.ecs_container_instance_profile.arn
      monitoring               = "BASIC"
      capacity_option_type     = "ON_DEMAND"

      network_configuration {
        subnets         = var.region.vpc.private_subnets
        security_groups = [aws_security_group.container_instance.id]
      }
    }
  }
}

resource "aws_ecs_service" "appserver" {
  name                 = aws_ecs_task_definition.appserver.family
  cluster              = aws_ecs_cluster.this.id
  task_definition      = aws_ecs_task_definition.appserver.arn
  desired_count        = var.appserver_min_tasks
  force_new_deployment = true

  network_configuration {
    subnets = var.region.vpc.private_subnets
    security_groups = [
      aws_security_group.appserver.id,
      aws_security_group.redis.id
    ]
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.appserver_managed.name
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

  load_balancer {
    target_group_arn = aws_lb_target_group.internal_webserver.arn
    container_name   = "nginx"
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [task_definition]
  }

  depends_on = [
    aws_iam_role.task_execution_role
  ]
}

# Route 53

resource "aws_route53_record" "api" {
  zone_id = var.route53_zone.zone_id
  name    = var.api_subdomain
  type    = "A"

  alias {
    name                   = var.global_accelerator.dns_name
    zone_id                = var.global_accelerator.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "app" {
  zone_id = var.route53_zone.zone_id
  name    = var.app_subdomain
  type    = "A"

  alias {
    name                   = var.global_accelerator.dns_name
    zone_id                = var.global_accelerator.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "app_subdomains" {
  zone_id = var.route53_zone.zone_id
  name    = "*.${var.app_subdomain}"
  type    = "A"

  alias {
    name                   = var.global_accelerator.dns_name
    zone_id                = var.global_accelerator.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "cdn" {
  zone_id = var.route53_zone.zone_id
  name    = var.cdn_subdomain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.app.domain_name
    zone_id                = aws_cloudfront_distribution.app.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "verify" {
  zone_id = var.route53_zone.zone_id
  name    = var.verify_subdomain
  type    = "A"

  alias {
    name                   = var.global_accelerator.dns_name
    zone_id                = var.global_accelerator.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "internal_api" {
  zone_id = var.internal_route53_zone.zone_id
  name    = var.api_subdomain
  type    = "A"

  alias {
    name                   = var.region.internal_load_balancer.this.dns_name
    zone_id                = var.region.internal_load_balancer.this.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "services" {
  zone_id = var.internal_route53_zone.zone_id
  name    = var.services_subdomain
  type    = "A"

  alias {
    name                   = var.region.internal_load_balancer.this.dns_name
    zone_id                = var.region.internal_load_balancer.this.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "internal_app" {
  zone_id = var.internal_route53_zone.zone_id
  name    = var.app_subdomain
  type    = "A"

  alias {
    name                   = var.region.internal_load_balancer.this.dns_name
    zone_id                = var.region.internal_load_balancer.this.zone_id
    evaluate_target_health = true
  }
}

# Target groups

resource "aws_lb_target_group" "webserver" {
  name                 = var.app_identifier
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = var.region.vpc.vpc_id
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

  listener_arn = var.region.public_load_balancer.https_listener.arn

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

resource "aws_lb_target_group" "internal_webserver" {
  name                 = "${aws_lb_target_group.webserver.name}-internal"
  port                 = aws_lb_target_group.webserver.port
  protocol             = aws_lb_target_group.webserver.protocol
  vpc_id               = aws_lb_target_group.webserver.vpc_id
  target_type          = aws_lb_target_group.webserver.target_type
  deregistration_delay = aws_lb_target_group.webserver.deregistration_delay

  health_check {
    protocol          = aws_lb_target_group.webserver.health_check[0].protocol
    path              = aws_lb_target_group.webserver.health_check[0].path
    healthy_threshold = aws_lb_target_group.webserver.health_check[0].healthy_threshold
    interval          = aws_lb_target_group.webserver.health_check[0].interval
  }
}

resource "aws_lb_listener_rule" "internal_webserver" {
  priority = var.app_environment == "production" ? 15 : 115

  listener_arn = var.region.internal_load_balancer.https_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal_webserver.id
  }

  condition {
    host_header {
      values = [
        aws_route53_record.internal_api.fqdn,
        aws_route53_record.services.fqdn
      ]
    }
  }
}

# Autoscaling

resource "aws_appautoscaling_target" "appserver_scale_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.appserver.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  max_capacity       = var.appserver_max_tasks
  min_capacity       = var.appserver_min_tasks
}

resource "aws_appautoscaling_policy" "appserver_cpu_utilization" {
  name               = "${var.app_identifier}-cpu-utilization"
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

resource "aws_appautoscaling_policy" "appserver_memory_utilization" {
  name               = "${var.app_identifier}-memory-utilization"
  service_namespace  = aws_appautoscaling_target.appserver_scale_target.service_namespace
  resource_id        = aws_appautoscaling_target.appserver_scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.appserver_scale_target.scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value       = 85
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}
