resource "aws_ecs_cluster" "cluster" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

data "template_file" "appserver_container_definitions" {
  template = file("${path.module}/templates/appserver_container_definitions.json.tpl")

  vars = {
    name = var.app_identifier
    app_port = var.app_port
    app_image      = var.app_image
    nginx_image      = var.nginx_image
    webserver_container_name = var.webserver_container_name
    webserver_container_port = var.webserver_container_port
    region = var.aws_region
    aws_ses_region = var.aws_ses_region
    aws_sqs_high_priority_queue_name = aws_sqs_queue.high_priority.name
    aws_sqs_default_queue_name = aws_sqs_queue.default.name
    aws_sqs_low_priority_queue_name = aws_sqs_queue.low_priority.name
    aws_sqs_scheduler_queue_name = aws_sqs_queue.scheduler.name
    memory = var.memory
    nginx_logs_group = aws_cloudwatch_log_group.nginx.name
    app_logs_group = aws_cloudwatch_log_group.app.name
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
  }
}

resource "aws_ecs_task_definition" "appserver" {
  family                   = "${var.app_identifier}-appserver"
  network_mode             = var.network_mode
  requires_compatibilities = [var.launch_type]
  container_definitions = data.template_file.appserver_container_definitions.rendered
  task_role_arn = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.task_execution_role.arn
  cpu = var.cpu
  memory = var.memory
}

resource "aws_ecs_service" "appserver" {
  name            = "${var.app_identifier}-appserver"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.appserver.arn
  desired_count   = var.ecs_appserver_autoscale_min_instances
  launch_type = var.launch_type

  network_configuration {
    subnets = var.container_instance_subnets
    security_groups = [aws_security_group.appserver.id, var.db_security_group, var.redis_security_group]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.webserver.arn
    container_name   = var.webserver_container_name
    container_port   = var.webserver_container_port
  }

  lifecycle {
    ignore_changes = [load_balancer, task_definition]
  }
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
    memory = var.memory
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
  }
}

resource "aws_ecs_task_definition" "worker" {
  family                   = "${var.app_identifier}-worker"
  network_mode             = var.network_mode
  requires_compatibilities = [var.launch_type]
  container_definitions = data.template_file.worker_container_definitions.rendered
  task_role_arn = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.task_execution_role.arn
  cpu = var.cpu
  memory = var.memory
}

resource "aws_ecs_service" "worker" {
  name            = "${var.app_identifier}-worker"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.worker.arn
  desired_count   = var.ecs_worker_autoscale_min_instances
  launch_type = var.launch_type

  network_configuration {
    subnets = var.container_instance_subnets
    security_groups = [aws_security_group.worker.id, var.db_security_group, var.redis_security_group]
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}
