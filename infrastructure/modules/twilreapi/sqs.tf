resource "aws_sqs_queue" "high_priority" {
  name           = "${var.app_identifier}-high-priority"
  redrive_policy = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead_letter.arn}\",\"maxReceiveCount\":10}"
  visibility_timeout_seconds = var.sqs_visibility_timeout_seconds
}

resource "aws_sqs_queue" "default" {
  name           = "${var.app_identifier}-default"
  redrive_policy = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead_letter.arn}\",\"maxReceiveCount\":10}"
  visibility_timeout_seconds = var.sqs_visibility_timeout_seconds
}

resource "aws_sqs_queue" "low_priority" {
  name           = "${var.app_identifier}-low-priority"
  redrive_policy = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead_letter.arn}\",\"maxReceiveCount\":10}"
  visibility_timeout_seconds = var.sqs_visibility_timeout_seconds
}

resource "aws_sqs_queue" "scheduler" {
  name = "${var.app_identifier}-scheduler"
  redrive_policy = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead_letter.arn}\",\"maxReceiveCount\":10}"
  visibility_timeout_seconds = var.sqs_visibility_timeout_seconds
}

resource "aws_sqs_queue" "dead_letter" {
  name = "${var.app_identifier}-dead-letter"
}
