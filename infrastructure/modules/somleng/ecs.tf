locals {
  shared_container_secrets = [
    {
      name      = "RAILS_MASTER_KEY"
      valueFrom = aws_ssm_parameter.rails_master_key.arn
    },
    {
      name      = "DATABASE_PASSWORD"
      valueFrom = var.db_password_parameter_arn
    },
    {
      name      = "SERVICES_PASSWORD"
      valueFrom = aws_ssm_parameter.services_password.arn
    },
    {
      name      = "REGION_DATA"
      valueFrom = data.aws_ssm_parameter.region_data.arn
    },
    {
      name      = "CALL_SERVICE_PASSWORD"
      valueFrom = data.aws_ssm_parameter.call_service_password.arn
    },
    {
      name      = "RATING_ENGINE_PASSWORD"
      valueFrom = data.aws_ssm_parameter.rating_engine_password.arn
    }
  ]

  shared_container_healthcheck = {
    command  = ["CMD-SHELL", "wget --server-response --spider --quiet http://localhost:3000/health_checks 2>&1 | grep '200 OK' > /dev/null"],
    interval = 10,
    retries  = 10,
    timeout  = 5
  }

  shared_container_environment = [
    {
      name  = "RAILS_ENV",
      value = var.app_environment
    },
    {
      name  = "RACK_ENV",
      value = var.app_environment
    },
    {
      name  = "AWS_SQS_HIGH_PRIORITY_QUEUE_NAME",
      value = aws_sqs_queue.high_priority.name
    },
    {
      name  = "AWS_SQS_MEDIUM_PRIORITY_QUEUE_NAME",
      value = aws_sqs_queue.medium_priority.name
    },
    {
      name  = "AWS_SQS_DEFAULT_QUEUE_NAME",
      value = aws_sqs_queue.default.name
    },
    {
      name  = "AWS_SQS_LOW_PRIORITY_QUEUE_NAME",
      value = aws_sqs_queue.low_priority.name
    },
    {
      name  = "AWS_SQS_LONG_RUNNING_QUEUE_NAME",
      value = aws_sqs_queue.long_running.name
    },
    {
      name  = "AWS_SQS_OUTBOUND_CALLS_QUEUE_NAME",
      value = aws_sqs_queue.outbound_calls.name
    },
    {
      name  = "AWS_SQS_SCHEDULER_QUEUE_NAME",
      value = aws_sqs_queue.scheduler.name
    },
    {
      name  = "AWS_DEFAULT_REGION",
      value = var.region.aws_region
    },
    {
      name  = "AWS_SES_REGION",
      value = var.aws_ses_region
    },
    {
      name  = "DATABASE_NAME",
      value = var.db_name
    },
    {
      name  = "DATABASE_USERNAME",
      value = var.db_username
    },
    {
      name  = "DATABASE_HOST",
      value = var.db_host
    },
    {
      name  = "DATABASE_PORT",
      value = tostring(var.db_port)
    },
    {
      name  = "DB_POOL",
      value = tostring(var.db_pool)
    },
    {
      name  = "REDIS_URL",
      value = local.redis_url
    },
    {
      name  = "UPLOADS_BUCKET",
      value = aws_s3_bucket.uploads.id
    },
    {
      name  = "CALL_SERVICE_QUEUE_URL",
      value = data.aws_sqs_queue.call_service.url
    },
    {
      name  = "RAW_RECORDINGS_BUCKET",
      value = data.aws_s3_bucket.raw_recordings.bucket
    },
    {
      name  = "PGHERO_DB_INSTANCE_IDENTIFIER",
      value = var.db_instance_identifier
    },
    {
      name  = "PGHERO_OTHER_DATABASES",
      value = var.pghero_other_databases
    },
    {
      name  = "ANYCABLE_REDIS_CHANNEL",
      value = "__anycable__"
    },
    {
      name  = "ANYCABLE_BROADCAST_ADAPTER",
      value = "redisx"
    },
    {
      name  = "RAILS_LOG_LEVEL",
      value = var.rails_log_level
    }
  ]
}

resource "aws_ecs_cluster" "cluster" {
  name = var.app_identifier

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

# Capacity Provider
resource "aws_ecs_capacity_provider" "this" {
  name = var.app_identifier

  auto_scaling_group_provider {
    auto_scaling_group_arn         = module.container_instances.autoscaling_group.arn
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

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.cluster.name

  capacity_providers = [
    aws_ecs_capacity_provider.this.name,
    "FARGATE"
  ]
}
