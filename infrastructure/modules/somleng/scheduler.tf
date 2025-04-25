resource "aws_cloudwatch_event_rule" "scheduler_daily" {
  name                = "somleng-${var.app_environment}-SchedulerJob-daily"
  schedule_expression = "cron(0 0 * * ? *)"
}

resource "aws_cloudwatch_event_target" "scheduler_daily" {
  target_id = aws_cloudwatch_event_rule.scheduler_daily.name
  arn       = aws_sqs_queue.scheduler.arn
  rule      = aws_cloudwatch_event_rule.scheduler_daily.name

  input = <<DOC
{
  "job_class": "DailyJob"
}
DOC
}

resource "aws_cloudwatch_event_rule" "scheduler_hourly" {
  name                = "somleng-${var.app_environment}-SchedulerJob-hourly"
  schedule_expression = "cron(0 * * * ? *)"
}

resource "aws_cloudwatch_event_target" "scheduler_hourly" {
  target_id = aws_cloudwatch_event_rule.scheduler_hourly.name
  arn       = aws_sqs_queue.scheduler.arn
  rule      = aws_cloudwatch_event_rule.scheduler_hourly.name

  input = <<DOC
{
  "job_class": "HourlyJob"
}
DOC
}

resource "aws_cloudwatch_event_rule" "scheduler_per_minute" {
  name                = "somleng-${var.app_environment}-SchedulerJob-per-minute"
  schedule_expression = "cron(* * * * ? *)"
}

resource "aws_cloudwatch_event_target" "scheduler_per_minute" {
  target_id = aws_cloudwatch_event_rule.scheduler_per_minute.name
  arn       = aws_sqs_queue.scheduler.arn
  rule      = aws_cloudwatch_event_rule.scheduler_per_minute.name

  input = <<DOC
{
  "job_class": "PerMinuteJob"
}
DOC
}
