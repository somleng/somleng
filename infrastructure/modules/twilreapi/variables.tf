variable "cluster_name" {}
variable "app_identifier" {}
variable "app_environment" {}
variable "app_image" {}
variable "nginx_image" {}
variable "memory" {}
variable "cpu" {}
variable "aws_region" {}
variable "aws_ses_region" {}
variable "container_instance_subnets" {}
variable "vpc_id" {}
variable "uploads_bucket" {}
variable "load_balancer" {}
variable "global_accelerator" {}
variable "listener_arn" {}
variable "route53_zone" {}
variable "cdn_certificate" {}
variable "app_subdomain" {}
variable "cdn_subdomain" {}
variable "api_subdomain" {}

variable "call_service_queue_name" {}
variable "raw_recordings_bucket_name" {}

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

variable "db_name" {
}

variable "db_pool" {
  default = 48
}

variable "db_instance_identifier" {
  default = ""
}

variable "pghero_other_databases" {
  description = "A comma separated list of other databases to show in the pghero console"
  default = ""
}

variable "db_security_group" {}
variable "redis_security_group" {}
variable "redis_url" {}

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

variable "sqs_visibility_timeout_seconds" {
  default = 1800
}
