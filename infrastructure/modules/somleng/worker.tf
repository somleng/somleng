locals {
  worker_container_definitions = [
    {
      name  = "worker",
      image = "${var.app_image}:latest",
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.worker.name,
          awslogs-region        = var.region.aws_region,
          awslogs-stream-prefix = var.app_environment
        }
      },
      command      = ["bundle", "exec", "shoryuken", "-R", "-C", "config/shoryuken.yml"],
      startTimeout = 120,
      essential    = true,
      healthCheck  = local.shared_container_healthcheck,
      environment  = local.shared_container_environment,
      secrets      = local.shared_container_secrets
    }
  ]
}

# Security Group

resource "aws_security_group" "worker" {
  name   = "${var.app_identifier}-worker"
  vpc_id = var.region.vpc.vpc_id
}

resource "aws_security_group_rule" "worker_egress" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  security_group_id = aws_security_group.worker.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# Cloudwatch

resource "aws_cloudwatch_log_group" "worker" {
  name              = "${var.app_identifier}-worker"
  retention_in_days = 7
}

# ECS

resource "aws_ecs_task_definition" "worker" {
  family                   = "${var.app_identifier}-worker"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  container_definitions    = jsonencode(local.worker_container_definitions)
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  memory                   = module.container_instances.ec2_instance_type.memory_size - 768
}

resource "aws_ecs_task_definition" "worker_fargate" {
  family                   = "${var.app_identifier}-worker-fargate"
  network_mode             = aws_ecs_task_definition.worker.network_mode
  requires_compatibilities = ["FARGATE"]
  container_definitions    = jsonencode(local.worker_container_definitions)
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  memory                   = 1024
  cpu                      = 512

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
}

resource "aws_ecs_service" "worker" {
  name            = aws_ecs_task_definition.worker.family
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.worker.arn
  desired_count   = var.worker_min_tasks

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.this.name
    weight            = 1
  }

  placement_constraints {
    type = "distinctInstance"
  }

  network_configuration {
    subnets = var.region.vpc.private_subnets
    security_groups = [
      aws_security_group.worker.id,
      var.db_security_group,
      var.redis_security_group
    ]
  }

  depends_on = [
    aws_iam_role.task_execution_role
  ]

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

# Autoscaling

resource "aws_appautoscaling_policy" "worker_memory_utilization" {
  name               = var.app_identifier
  service_namespace  = aws_appautoscaling_target.worker_scale_target.service_namespace
  resource_id        = aws_appautoscaling_target.worker_scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.worker_scale_target.scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value       = 50
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

resource "aws_cloudwatch_metric_alarm" "worker_queue_size_alarm_high" {
  alarm_name          = "${var.app_identifier}-queue-size-alarm-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 1000

  metric_query {
    id          = "tm"
    return_data = true
    expression  = "sm + lrm + lpm + dpm + hpm"
    label       = "Total Number of Messages"
  }

  metric_query {
    id          = "dpm"
    return_data = false
    label       = "Number of default priority messages"
    metric {
      namespace   = "AWS/SQS"
      metric_name = "ApproximateNumberOfMessagesVisible"
      period      = 60 # Wait this number of seconds before triggering the alarm (smallest available)
      stat        = "Sum"
      dimensions = {
        QueueName = aws_sqs_queue.default.name
      }
    }
  }

  metric_query {
    id          = "sm"
    return_data = false
    label       = "Number of scheduler messages"
    metric {
      namespace   = "AWS/SQS"
      metric_name = "ApproximateNumberOfMessagesVisible"
      period      = 60 # Wait this number of seconds before triggering the alarm (smallest available)
      stat        = "Sum"
      dimensions = {
        QueueName = aws_sqs_queue.scheduler.name
      }
    }
  }

  metric_query {
    id          = "hpm"
    return_data = false
    label       = "Number of high priority messages"
    metric {
      namespace   = "AWS/SQS"
      metric_name = "ApproximateNumberOfMessagesVisible"
      period      = 60 # Wait this number of seconds before triggering the alarm (smallest available)
      stat        = "Sum"
      dimensions = {
        QueueName = aws_sqs_queue.high_priority.name
      }
    }
  }

  metric_query {
    id          = "lpm"
    return_data = false
    label       = "Number of low priority messages"
    metric {
      namespace   = "AWS/SQS"
      metric_name = "ApproximateNumberOfMessagesVisible"
      period      = 60 # Wait this number of seconds before triggering the alarm (smallest available)
      stat        = "Sum"
      dimensions = {
        QueueName = aws_sqs_queue.low_priority.name
      }
    }
  }

  metric_query {
    id          = "lrm"
    return_data = false
    label       = "Number of long running messages"
    metric {
      namespace   = "AWS/SQS"
      metric_name = "ApproximateNumberOfMessagesVisible"
      period      = 60 # Wait this number of seconds before triggering the alarm (smallest available)
      stat        = "Sum"
      dimensions = {
        QueueName = aws_sqs_queue.long_running.name
      }
    }
  }

  alarm_actions = [aws_appautoscaling_policy.worker_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "worker_queue_size_alarm_low" {
  alarm_name          = "${var.app_identifier}-queue-size-alarm-low"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 1

  metric_query {
    id          = "e1"
    return_data = true
    expression  = "tm < 500 && (lrm + lrmif) < 1"
    label       = "Total messages below threshold and no long running messages"
  }

  metric_query {
    id          = "tm"
    return_data = false
    expression  = "sm + lrm + lpm + dpm + hpm"
    label       = "Total Number of Messages"
  }

  metric_query {
    id          = "dpm"
    return_data = false
    label       = "Number of default priority messages"
    metric {
      namespace   = "AWS/SQS"
      metric_name = "ApproximateNumberOfMessagesVisible"
      period      = 300
      stat        = "Sum"
      dimensions = {
        QueueName = aws_sqs_queue.default.name
      }
    }
  }

  metric_query {
    id          = "sm"
    return_data = false
    label       = "Number of scheduler messages"
    metric {
      namespace   = "AWS/SQS"
      metric_name = "ApproximateNumberOfMessagesVisible"
      period      = 300
      stat        = "Sum"
      dimensions = {
        QueueName = aws_sqs_queue.scheduler.name
      }
    }
  }

  metric_query {
    id          = "hpm"
    return_data = false
    label       = "Number of high priority messages"
    metric {
      namespace   = "AWS/SQS"
      metric_name = "ApproximateNumberOfMessagesVisible"
      period      = 300
      stat        = "Sum"
      dimensions = {
        QueueName = aws_sqs_queue.high_priority.name
      }
    }
  }

  metric_query {
    id          = "lpm"
    return_data = false
    label       = "Number of low priority messages"
    metric {
      namespace   = "AWS/SQS"
      metric_name = "ApproximateNumberOfMessagesVisible"
      period      = 300
      stat        = "Sum"
      dimensions = {
        QueueName = aws_sqs_queue.low_priority.name
      }
    }
  }

  metric_query {
    id          = "lrm"
    return_data = false
    label       = "Number of long running messages"
    metric {
      namespace   = "AWS/SQS"
      metric_name = "ApproximateNumberOfMessagesVisible"
      period      = 300
      stat        = "Sum"
      dimensions = {
        QueueName = aws_sqs_queue.long_running.name
      }
    }
  }

  metric_query {
    id          = "lrmif"
    return_data = false
    label       = "Number of long running messages in flight"
    metric {
      namespace   = "AWS/SQS"
      metric_name = "ApproximateNumberOfMessagesNotVisible"
      period      = 300
      stat        = "Sum"
      dimensions = {
        QueueName = aws_sqs_queue.long_running.name
      }
    }
  }

  alarm_actions = [aws_appautoscaling_policy.worker_down.arn]
}

resource "aws_appautoscaling_policy" "worker_up" {
  name               = "worker-scale-up"
  service_namespace  = aws_appautoscaling_target.worker_scale_target.service_namespace
  resource_id        = aws_appautoscaling_target.worker_scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.worker_scale_target.scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300 # Don't run another autoscaling event for this number of seconds
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_appautoscaling_policy" "worker_down" {
  name               = "worker-scale-down"
  service_namespace  = aws_appautoscaling_target.worker_scale_target.service_namespace
  resource_id        = aws_appautoscaling_target.worker_scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.worker_scale_target.scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}

resource "aws_appautoscaling_target" "worker_scale_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.worker.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  max_capacity       = var.worker_max_tasks
  min_capacity       = var.worker_min_tasks
}
