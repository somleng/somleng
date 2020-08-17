resource "random_password" "rails_master_key" {
  length = 32
  special = true
}

resource "aws_ssm_parameter" "rails_master_key" {
  name  = "twilreapi.${var.app_environment}.rails_master_key"
  type  = "SecureString"
  value = random_password.rails_master_key.result

  lifecycle {
    ignore_changes = [value]
  }
}
