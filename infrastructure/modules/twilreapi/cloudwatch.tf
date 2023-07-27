resource "aws_cloudwatch_log_group" "nginx" {
  name = "${var.old_app_identifier}-nginx"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "app" {
  name = "${var.old_app_identifier}-app"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "worker" {
  name ="${var.old_app_identifier}-worker"
  retention_in_days = 7
}
