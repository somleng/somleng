module "somleng" {
  source = "../modules/somleng"

  app_identifier     = "somleng-staging"
  app_environment    = "staging"
  app_subdomain      = "app-staging"
  cdn_subdomain      = "cdn-staging"
  api_subdomain      = "api-staging"
  verify_subdomain   = "verify-staging"
  anycable_subdomain = "anycable-staging"

  app_image             = data.terraform_remote_state.core.outputs.app_ecr_repository
  nginx_image           = data.terraform_remote_state.core.outputs.nginx_ecr_repository
  aws_ses_region        = "us-east-1"
  region                = data.terraform_remote_state.core_infrastructure.outputs.hydrogen_region
  global_accelerator    = data.terraform_remote_state.core_infrastructure.outputs.global_accelerator
  route53_zone          = data.terraform_remote_state.core_infrastructure.outputs.route53_zone_somleng_org
  internal_route53_zone = data.terraform_remote_state.core_infrastructure.outputs.route53_zone_internal_somleng_org

  cdn_certificate = data.terraform_remote_state.core_infrastructure.outputs.cdn_certificate

  uploads_bucket = "uploads-staging.somleng.org"

  db_name                   = "somleng_staging"
  db_username               = data.terraform_remote_state.core_infrastructure.outputs.db.this.master_username
  db_password_parameter_arn = data.terraform_remote_state.core_infrastructure.outputs.db.master_password_parameter.arn
  db_host                   = data.terraform_remote_state.core_infrastructure.outputs.db.this.endpoint
  db_port                   = data.terraform_remote_state.core_infrastructure.outputs.db.this.port
  db_security_group         = data.terraform_remote_state.core_infrastructure.outputs.db.security_group.id
  db_instance_identifier    = data.terraform_remote_state.core_infrastructure.outputs.db.this.id

  call_service_queue_name = "switch-services-staging"

  appserver_min_tasks = 0
  appserver_max_tasks = 1
  worker_min_tasks    = 0
  worker_max_tasks    = 1
  anycable_min_tasks  = 0
  anycable_max_tasks  = 1
  ws_min_tasks        = 0
  ws_max_tasks        = 1

  raw_recordings_bucket_name = "raw-recordings-staging.somleng.org"
  pghero_other_databases     = "opensips_public_gateway_staging,opensips_client_gateway_staging"
}
