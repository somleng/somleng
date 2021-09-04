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
