resource "aws_cloudwatch_log_group" "nginx" {
  name              = "${var.app_identifier}-nginx"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "appserver" {
  name              = "${var.app_identifier}-appserver"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "worker" {
  name              = "${var.app_identifier}-worker"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "anycable" {
  name              = "${var.app_identifier}-anycable"
  retention_in_days = 7
}
