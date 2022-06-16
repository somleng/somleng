resource "aws_cloudwatch_event_rule" "scheduler_daily" {
  name                = "somleng-SchedulerJob-daily"
  schedule_expression =  "cron(0 0 * * ? *)"
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
