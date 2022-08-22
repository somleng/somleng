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
      "Resource": "arn:aws:sqs:*:*:${var.app_identifier}-scheduler",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_cloudwatch_event_rule.scheduler_daily.arn}"
        }
      }
    }
  ]
}
DOC
}

resource "aws_sqs_queue" "dead_letter" {
  name = "${var.app_identifier}-dead-letter"
}

data "aws_sqs_queue" "switch_services" {
  name = var.switch_services_queue_name
}


