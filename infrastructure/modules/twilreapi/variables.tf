variable "ecs_cluster" {}
variable "app_identifier" {}
variable "app_environment" {}
variable "app_image" {}
variable "nginx_image" {}
variable "memory" {}
variable "cpu" {}
variable "aws_region" {}
variable "container_instance_subnets" {}
variable "vpc_id" {}
variable "codedeploy_role" {}
variable "uploads_bucket" {}
variable "load_balancer" {}
variable "listener_arn" {}
variable "route53_zone" {}
variable "cdn_certificate" {}
variable "dashboard_subdomain" {}
variable "api_subdomain" {}

variable "webserver_container_name" {
  default = "nginx"
}
variable "webserver_container_port" {
  default = 80
}

variable "app_port" {
  default = 3000
}
variable "network_mode" {
  default = "awsvpc"
}
variable "launch_type" {
  default = "FARGATE"
}

variable "db_host" {
}

variable "db_port" {
}

variable "db_pool" {
  default = 48
}

variable "db_security_group" {
}

variable "db_username" {}
variable "db_password_parameter_arn" {}
variable "enable_dashboard" {
  default = false
}
variable "ecs_appserver_autoscale_max_instances" {
  default = 4
}
variable "ecs_appserver_autoscale_min_instances" {
  default = 1
}
variable "ecs_worker_autoscale_max_instances" {
  default = 4
}
variable "ecs_worker_autoscale_min_instances" {
  default = 1
}
# If the average CPU utilization over a minute drops to this threshold,
# the number of containers will be reduced (but not below ecs_autoscale_min_instances).
variable "ecs_as_cpu_low_threshold_per" {
  default = "30"
}

# If the average CPU utilization over a minute rises to this threshold,
# the number of containers will be increased (but not above ecs_autoscale_max_instances).
variable "ecs_as_cpu_high_threshold_per" {
  default = "70"
}

variable "scheduler_schedule" {
  default = "cron(* * * * ? *)"
}

variable "sqs_visibility_timeout_seconds" {
  default = 1800
}
