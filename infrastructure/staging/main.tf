module "somleng" {
  source = "../modules/somleng"

  cluster_name       = "somleng-staging"
  app_identifier     = "somleng-staging"
  app_environment    = "staging"
  app_subdomain      = "app-staging"
  cdn_subdomain      = "cdn-staging"
  api_subdomain      = "api-staging"
  verify_subdomain   = "verify-staging"
  anycable_subdomain = "anycable-staging"

  app_image                          = data.terraform_remote_state.core.outputs.app_ecr_repository
  nginx_image                        = data.terraform_remote_state.core.outputs.nginx_ecr_repository
  aws_region                         = var.aws_region
  aws_ses_region                     = "us-east-1"
  global_accelerator                 = data.terraform_remote_state.core_infrastructure.outputs.global_accelerator
  listener_arn                       = data.terraform_remote_state.core_infrastructure.outputs.https_listener.arn
  internal_load_balancer             = data.terraform_remote_state.core_infrastructure.outputs.internal_application_load_balancer
  route53_zone                       = data.terraform_remote_state.core_infrastructure.outputs.route53_zone_somleng_org
  internal_route53_zone              = data.terraform_remote_state.core_infrastructure.outputs.route53_zone_internal_somleng_org
  cdn_certificate                    = data.terraform_remote_state.core_infrastructure.outputs.cdn_certificate
  load_balancer_certificate          = data.terraform_remote_state.core_infrastructure.outputs.acm_certificate
  internal_load_balancer_certificate = data.terraform_remote_state.core_infrastructure.outputs.internal_certificate

  vpc            = data.terraform_remote_state.core_infrastructure.outputs.vpc
  uploads_bucket = "uploads-staging.somleng.org"

  db_name                   = "somleng_staging"
  db_username               = data.terraform_remote_state.core_infrastructure.outputs.db_cluster.master_username
  db_password_parameter_arn = data.terraform_remote_state.core_infrastructure.outputs.db_master_password_parameter.arn
  db_host                   = data.terraform_remote_state.core_infrastructure.outputs.db_cluster.endpoint
  db_port                   = data.terraform_remote_state.core_infrastructure.outputs.db_cluster.port
  db_security_group         = data.terraform_remote_state.core_infrastructure.outputs.db_security_group.id
  db_instance_identifier    = data.terraform_remote_state.core_infrastructure.outputs.db_cluster.id

  redis_security_group = data.terraform_remote_state.core.outputs.redis_security_group.id
  redis_url            = "redis://${data.terraform_remote_state.core.outputs.elasticache_redis_endpoint}/1"

  anycable_rpc_port = 50052

  call_service_queue_name = "switch-services-staging"

  appserver_min_tasks = 0
  worker_min_tasks    = 0
  appserver_max_tasks = 1
  worker_max_tasks    = 1
  anycable_min_tasks  = 0
  anycable_max_tasks  = 1

  raw_recordings_bucket_name = "raw-recordings-staging.somleng.org"
  pghero_other_databases     = "opensips_public_gateway_staging,opensips_client_gateway_staging"
}
