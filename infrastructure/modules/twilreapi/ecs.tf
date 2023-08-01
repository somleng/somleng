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

data "template_file" "appserver_container_definitions" {
  template = file("${path.module}/templates/appserver_container_definitions.json.tpl")

  vars = {
    name = var.app_identifier
    app_image      = var.app_image
    nginx_image      = var.nginx_image
    region = var.aws_region
    aws_ses_region = var.aws_ses_region
    aws_sqs_high_priority_queue_name = aws_sqs_queue.high_priority.name
    aws_sqs_default_queue_name = aws_sqs_queue.default.name
    aws_sqs_low_priority_queue_name = aws_sqs_queue.low_priority.name
    aws_sqs_scheduler_queue_name = aws_sqs_queue.scheduler.name
    nginx_logs_group = aws_cloudwatch_log_group.nginx.name
    appserver_logs_group = aws_cloudwatch_log_group.appserver.name
    logs_group_region = var.aws_region
    app_environment = var.app_environment
    rails_master_key_parameter_arn = aws_ssm_parameter.rails_master_key.arn
    services_password_parameter_arn = aws_ssm_parameter.services_password.arn
    database_password_parameter_arn = var.db_password_parameter_arn
    database_name = var.db_name
    database_username = var.db_username
    database_host = var.db_host
    database_port = var.db_port
    db_pool = var.db_pool
    uploads_bucket = aws_s3_bucket.uploads.id
    call_service_queue_url = data.aws_sqs_queue.call_service.url
    raw_recordings_bucket_name = data.aws_s3_bucket.raw_recordings.bucket
    redis_url = var.redis_url
    pghero_db_instance_identifier = var.db_instance_identifier
    pghero_other_databases = var.pghero_other_databases
  }
}

resource "aws_ecs_task_definition" "appserver" {
  family                   = "${var.app_identifier}-appserver"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  container_definitions = data.template_file.appserver_container_definitions.rendered
  task_role_arn = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.task_execution_role.arn
  memory = module.container_instances.ec2_instance_type.memory_size - 256
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
    weight = 1
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

data "template_file" "worker_container_definitions" {
  template = file("${path.module}/templates/worker_container_definitions.json.tpl")

  vars = {
    name = var.app_identifier
    app_image      = var.app_image
    region = var.aws_region
    aws_ses_region = var.aws_ses_region
    aws_sqs_high_priority_queue_name = aws_sqs_queue.high_priority.name
    aws_sqs_default_queue_name = aws_sqs_queue.default.name
    aws_sqs_low_priority_queue_name = aws_sqs_queue.low_priority.name
    aws_sqs_scheduler_queue_name = aws_sqs_queue.scheduler.name
    worker_logs_group = aws_cloudwatch_log_group.worker.name
    logs_group_region = var.aws_region
    app_environment = var.app_environment
    rails_master_key_parameter_arn = aws_ssm_parameter.rails_master_key.arn
    services_password_parameter_arn = aws_ssm_parameter.services_password.arn
    database_password_parameter_arn = var.db_password_parameter_arn
    database_name = var.db_name
    database_username = var.db_username
    database_host = var.db_host
    database_port = var.db_port
    db_pool = var.db_pool
    uploads_bucket = aws_s3_bucket.uploads.id
    call_service_queue_url = data.aws_sqs_queue.call_service.url
    raw_recordings_bucket_name = data.aws_s3_bucket.raw_recordings.bucket
    redis_url = var.redis_url
    pghero_db_instance_identifier = var.db_instance_identifier
    pghero_other_databases = var.pghero_other_databases
  }
}

resource "aws_ecs_task_definition" "worker" {
  family                   = "${var.app_identifier}-worker"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  container_definitions = data.template_file.worker_container_definitions.rendered
  task_role_arn = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.task_execution_role.arn
  memory = module.container_instances.ec2_instance_type.memory_size - 256
}

resource "aws_ecs_service" "worker" {
  name            = aws_ecs_task_definition.worker.family
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.worker.arn
  desired_count   = var.worker_min_tasks

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.this.name
    weight = 1
  }

  network_configuration {
    subnets = var.vpc.private_subnets
    security_groups = [
      aws_security_group.worker.id,
      var.db_security_group
    ]
  }

  depends_on = [
    aws_iam_role.task_execution_role
  ]

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}
