resource "aws_cloudwatch_event_rule" "scheduler_pg_hero_capture_query_stats_job" {
  name                = "somleng-${var.app_environment}-SchedulerJob-pg-hero-capture_query_stats"
  schedule_expression =  "cron(*/5 * * * ? *)"
}

resource "aws_cloudwatch_event_target" "scheduler_pg_hero_capture_query_stats_job" {
  target_id = aws_cloudwatch_event_rule.scheduler_pg_hero_capture_query_stats_job.name
  arn       = aws_sqs_queue.scheduler.arn
  rule      = aws_cloudwatch_event_rule.scheduler_pg_hero_capture_query_stats_job.name

  input = <<DOC
{
  "job_class": "PgHeroCaptureQueryStatsJob"
}
DOC
}

resource "aws_iam_policy" "pg_hero" {
  name = "somleng-${var.app_environment}-pg-hero"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "cloudwatch:GetMetricStatistics",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "pg_hero" {
  role = aws_iam_role.ecs_task_role.id
  policy_arn = aws_iam_policy.pg_hero.arn
}

