module "somleng" {
  source = "../modules/somleng"

  app_identifier = "somleng"

  app_environment    = "production"
  app_subdomain      = "app"
  cdn_subdomain      = "cdn"
  api_subdomain      = "api"
  verify_subdomain   = "verify"
  anycable_subdomain = "anycable"

  rating_engine_identifier = "rating-engine"

  app_image             = data.terraform_remote_state.core.outputs.app_ecr_repository
  nginx_image           = data.terraform_remote_state.core.outputs.nginx_ecr_repository
  region                = data.terraform_remote_state.core_infrastructure.outputs.hydrogen_region
  aws_ses_region        = "us-east-1"
  global_accelerator    = data.terraform_remote_state.core_infrastructure.outputs.global_accelerator
  route53_zone          = data.terraform_remote_state.core_infrastructure.outputs.route53_zone_somleng_org
  internal_route53_zone = data.terraform_remote_state.core_infrastructure.outputs.route53_zone_internal_somleng_org
  cdn_certificate       = data.terraform_remote_state.core_infrastructure.outputs.cdn_certificate
  uploads_bucket        = "uploads.twilreapi.somleng.org"

  db_name                   = "somleng"
  db_username               = data.terraform_remote_state.core_infrastructure.outputs.db.this.master_username
  db_password_parameter_arn = data.terraform_remote_state.core_infrastructure.outputs.db.master_password_parameter.arn
  db_host                   = data.terraform_remote_state.core_infrastructure.outputs.db.this.endpoint
  db_port                   = data.terraform_remote_state.core_infrastructure.outputs.db.this.port
  db_security_group         = data.terraform_remote_state.core_infrastructure.outputs.db.security_group.id
  db_instance_identifier    = data.terraform_remote_state.core_infrastructure.outputs.db.this.id

  call_service_queue_name = "switch-services"

  worker_min_tasks = 1
  worker_max_tasks = 10

  raw_recordings_bucket_name = "raw-recordings.somleng.org"
  pghero_other_databases     = "opensips_public_gateway,opensips_client_gateway"
}
