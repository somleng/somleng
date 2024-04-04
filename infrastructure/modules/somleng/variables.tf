variable "cluster_name" {}
variable "app_identifier" {}
variable "app_environment" {}
variable "app_image" {}
variable "nginx_image" {}
variable "aws_region" {}
variable "aws_ses_region" {}
variable "vpc" {}
variable "uploads_bucket" {}
variable "global_accelerator" {}
variable "listener_arn" {}
variable "internal_load_balancer" {}
variable "route53_zone" {}
variable "internal_route53_zone" {}
variable "cdn_certificate" {}
variable "load_balancer_certificate" {}
variable "internal_load_balancer_certificate" {}
variable "app_subdomain" {}
variable "cdn_subdomain" {}
variable "api_subdomain" {}
variable "verify_subdomain" {}
variable "anycable_subdomain" {}

variable "call_service_queue_name" {}
variable "raw_recordings_bucket_name" {}

variable "db_host" {}

variable "db_port" {}

variable "db_name" {}

variable "db_pool" {
  default = 48
}

variable "db_instance_identifier" {
  default = ""
}

variable "pghero_other_databases" {
  description = "A comma separated list of other databases to show in the pghero console"
  default     = ""
}

variable "db_security_group" {}
variable "redis_security_group" {}
variable "redis_url" {}
variable "db_username" {}
variable "db_password_parameter_arn" {}
variable "appserver_max_tasks" {
  default = 4
}
variable "appserver_min_tasks" {
  default = 1
}
variable "worker_max_tasks" {
  default = 4
}
variable "worker_min_tasks" {
  default = 1
}
variable "anycable_max_tasks" {
  default = 4
}
variable "anycable_min_tasks" {
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

variable "anycable_rpc_port" {
  default = 50051
}
