data "aws_ssm_parameter" "smtp_username" {
  name = "somleng.smtp_username"
}

data "aws_ssm_parameter" "smtp_password" {
  name = "somleng.smtp_password"
}
