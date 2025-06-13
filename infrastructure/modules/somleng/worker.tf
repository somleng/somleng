locals {
  worker_container_definitions = [
    {
      name  = "worker",
      image = "${var.app_image}:latest",
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.app.name,
          awslogs-region        = var.region.aws_region,
          awslogs-stream-prefix = "${var.app_identifier}/${var.app_environment}"
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

    target_value       = 75
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_policy" "worker_queue_size" {
  name               = "${var.app_identifier}-queue-size"
  service_namespace  = aws_appautoscaling_target.worker_scale_target.service_namespace
  resource_id        = aws_appautoscaling_target.worker_scale_target.resource_id
  scalable_dimension = aws_appautoscaling_target.worker_scale_target.scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    customized_metric_specification {
      metrics {
        id          = "backlogPerWorker"
        label       = "Backlog per worker instance"
        expression  = "totalMessages / IF((runningCapacity - 3) > 0, (runningCapacity - 3), 1)"
        return_data = true
      }

      metrics {
        id          = "totalMessages"
        label       = "Total number of messages"
        expression  = "longRunningMessages + lowPriorityMessages + defaultPriorityMessages + mediumPriorityMessages + highPriorityMessages + outboundCallMessages"
        return_data = false
      }

      metrics {
        id          = "runningCapacity"
        label       = "Number of running instances in ASG"
        return_data = false

        metric_stat {
          metric {
            metric_name = "GroupInServiceInstances"
            namespace   = "AWS/AutoScaling"

            dimensions {
              name  = "AutoScalingGroupName"
              value = module.container_instances.autoscaling_group.name
            }
          }
          stat = "Sum"
        }
      }

      metrics {
        id          = "lowPriorityMessages"
        label       = "Number of low priority messages"
        return_data = false
        metric_stat {
          metric {
            namespace   = "AWS/SQS"
            metric_name = "ApproximateNumberOfMessagesVisible"
            dimensions {
              name  = "QueueName"
              value = aws_sqs_queue.low_priority.name
            }
          }
          stat = "Sum"
        }
      }

      metrics {
        id          = "defaultPriorityMessages"
        label       = "Number of default priority messages"
        return_data = false
        metric_stat {
          metric {
            namespace   = "AWS/SQS"
            metric_name = "ApproximateNumberOfMessagesVisible"
            dimensions {
              name  = "QueueName"
              value = aws_sqs_queue.default.name
            }
          }
          stat = "Sum"
        }
      }

      metrics {
        id          = "mediumPriorityMessages"
        label       = "Number of medium priority messages"
        return_data = false
        metric_stat {
          metric {
            namespace   = "AWS/SQS"
            metric_name = "ApproximateNumberOfMessagesVisible"
            dimensions {
              name  = "QueueName"
              value = aws_sqs_queue.medium_priority.name
            }
          }
          stat = "Sum"
        }
      }

      metrics {
        id          = "highPriorityMessages"
        label       = "Number of high priority messages"
        return_data = false
        metric_stat {
          metric {
            namespace   = "AWS/SQS"
            metric_name = "ApproximateNumberOfMessagesVisible"
            dimensions {
              name  = "QueueName"
              value = aws_sqs_queue.high_priority.name
            }
          }
          stat = "Sum"
        }
      }

      metrics {
        id          = "outboundCallMessages"
        label       = "Number of outbound call messages"
        return_data = false
        metric_stat {
          metric {
            namespace   = "AWS/SQS"
            metric_name = "ApproximateNumberOfMessagesVisible"
            dimensions {
              name  = "QueueName"
              value = aws_sqs_queue.outbound_calls.name
            }
          }
          stat = "Sum"
        }
      }

      metrics {
        id          = "longRunningMessages"
        label       = "Number of long running messages"
        return_data = false
        metric_stat {
          metric {
            namespace   = "AWS/SQS"
            metric_name = "ApproximateNumberOfMessagesVisible"
            dimensions {
              name  = "QueueName"
              value = aws_sqs_queue.long_running.name
            }
          }
          stat = "Sum"
        }
      }
    }

    target_value       = 300
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_target" "worker_scale_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.worker.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  max_capacity       = var.worker_max_tasks
  min_capacity       = var.worker_min_tasks
}
