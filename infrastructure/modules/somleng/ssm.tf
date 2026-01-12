data "aws_ssm_parameter" "region_data" {
  name = "somleng.${var.app_environment}.region_data"
}

data "aws_ssm_parameter" "call_service_password" {
  name = "somleng-switch.${var.app_environment}.http_password"
}

data "aws_ssm_parameter" "rating_engine_password" {
  name = "${var.rating_engine_identifier}.http_password"
}

resource "aws_ssm_parameter" "rails_master_key" {
  name  = "somleng.${var.app_environment}.rails_master_key"
  type  = "SecureString"
  value = "change-me"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "services_password" {
  name  = "somleng.${var.app_environment}.services_password"
  type  = "SecureString"
  value = "change-me"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "anycable_secret" {
  name  = "somleng.${var.app_environment}.anycable_secret"
  type  = "SecureString"
  value = "change-me"

  lifecycle {
    ignore_changes = [value]
  }
}
