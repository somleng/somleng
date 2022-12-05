module "twilreapi" {
  source = "../modules/twilreapi"

  cluster_name = "somleng"
  app_identifier = "twilreapi"
  app_environment = "production"
  app_subdomain = "app"
  cdn_subdomain = "cdn"
  api_subdomain = "api"

  app_image = data.terraform_remote_state.core.outputs.app_ecr_repository
  nginx_image = data.terraform_remote_state.core.outputs.nginx_ecr_repository
  memory = 1024
  cpu = 512
  aws_region = var.aws_region
  aws_ses_region = "us-east-1"
  load_balancer = data.terraform_remote_state.core_infrastructure.outputs.application_load_balancer
  listener_arn = data.terraform_remote_state.core_infrastructure.outputs.https_listener.arn
  route53_zone = data.terraform_remote_state.core_infrastructure.outputs.route53_zone_somleng_org
  cdn_certificate = data.terraform_remote_state.core_infrastructure.outputs.cdn_certificate
  container_instance_subnets = data.terraform_remote_state.core_infrastructure.outputs.vpc.private_subnets
  vpc_id = data.terraform_remote_state.core_infrastructure.outputs.vpc.vpc_id
  uploads_bucket = "uploads.twilreapi.somleng.org"

  db_name = "somleng"
  db_username = data.terraform_remote_state.core_infrastructure.outputs.db_cluster.master_username
  db_password_parameter_arn = data.terraform_remote_state.core_infrastructure.outputs.db_master_password_parameter.arn
  db_host = data.terraform_remote_state.core_infrastructure.outputs.db_cluster.endpoint
  db_port = data.terraform_remote_state.core_infrastructure.outputs.db_cluster.port
  db_security_group = data.terraform_remote_state.core_infrastructure.outputs.db_security_group.id
  redis_url = "redis://${data.terraform_remote_state.core.outputs.elasticache_redis_endpoint}/0"

  call_service_queue_name = "switch-services"

  ecs_worker_autoscale_min_instances = 1
  ecs_worker_autoscale_max_instances = 10

  raw_recordings_bucket_name = "raw-recordings.somleng.org"
}
