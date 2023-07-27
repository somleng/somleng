locals {
  sqs_max_receive_count = 15
}

resource "aws_sqs_queue" "high_priority" {
  name                       = "${var.old_app_identifier}-high-priority"
  redrive_policy             = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead_letter.arn}\",\"maxReceiveCount\":${local.sqs_max_receive_count}}"
  visibility_timeout_seconds = var.sqs_visibility_timeout_seconds
}

resource "aws_sqs_queue" "default" {
  name                       = "${var.old_app_identifier}-default"
  redrive_policy             = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead_letter.arn}\",\"maxReceiveCount\":${local.sqs_max_receive_count}}"
  visibility_timeout_seconds = var.sqs_visibility_timeout_seconds
}

resource "aws_sqs_queue" "low_priority" {
  name                       = "${var.old_app_identifier}-low-priority"
  redrive_policy             = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead_letter.arn}\",\"maxReceiveCount\":${local.sqs_max_receive_count}}"
  visibility_timeout_seconds = var.sqs_visibility_timeout_seconds
}

resource "aws_sqs_queue" "scheduler" {
  name                       = "${var.old_app_identifier}-scheduler"
  redrive_policy             = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.dead_letter.arn}\",\"maxReceiveCount\":${local.sqs_max_receive_count}}"
  visibility_timeout_seconds = var.sqs_visibility_timeout_seconds

  policy = <<DOC
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sqs:SendMessage",
      "Resource": "arn:aws:sqs:*:*:${var.old_app_identifier}-scheduler",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "arn:aws:events:*:*:rule/somleng-${var.app_environment}-SchedulerJob-*"
        }
      }
    }
  ]
}
DOC
}

resource "aws_sqs_queue" "dead_letter" {
  name = "${var.old_app_identifier}-dead-letter"
}

data "aws_sqs_queue" "call_service" {
  name = var.call_service_queue_name
}


