resource "aws_ecs_cluster" "cluster" {
  name = var.cluster_name

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
  cluster_name = var.cluster_name

  capacity_providers = [
    aws_ecs_capacity_provider.this.name,
    "FARGATE"
  ]
}

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
      name  = "AWS_SQS_SCHEDULER_QUEUE_NAME",
      value = aws_sqs_queue.scheduler.name
    },
    {
      name  = "AWS_DEFAULT_REGION",
      value = var.aws_region
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
      value = var.redis_url
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
    }
  ]
}

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

resource "aws_ecs_task_definition" "worker" {
  family                   = "${var.app_identifier}-worker"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  container_definitions = jsonencode(
    [
      {
        name  = "worker",
        image = "${var.app_image}:latest",
        logConfiguration = {
          logDriver = "awslogs",
          options = {
            awslogs-group         = aws_cloudwatch_log_group.worker.name,
            awslogs-region        = var.aws_region,
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
  )

  task_role_arn      = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.task_execution_role.arn
  memory             = module.container_instances.ec2_instance_type.memory_size - 768
}

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
            awslogs-group         = aws_cloudwatch_log_group.anycable.name,
            awslogs-region        = var.aws_region,
            awslogs-stream-prefix = var.app_environment
          }
        },
        command      = ["bundle", "exec", "shoryuken", "-R", "-C", "config/shoryuken.yml"],
        startTimeout = 120,
        essential    = true,
        healthCheck = {
          command  = ["CMD-SHELL", "grpc-health-probe -addr :$ANYCABLE_RPC_PORT}"],
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
            }
          ]
        )
        secrets = local.shared_container_secrets
      }
    ]
  )

  task_role_arn      = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.task_execution_role.arn
  memory             = module.container_instances.ec2_instance_type.memory_size - 768
}

resource "aws_ecs_task_definition" "worker_fargate" {
  family                   = "${var.app_identifier}-worker-fargate"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = aws_ecs_task_definition.worker.container_definitions
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
    subnets = var.vpc.private_subnets
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
    subnets = var.vpc.private_subnets
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
