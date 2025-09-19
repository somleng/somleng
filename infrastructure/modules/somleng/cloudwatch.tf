resource "aws_cloudwatch_log_group" "app" {
  name              = var.app_identifier
  retention_in_days = 7
}

resource "aws_cloudwatch_log_metric_filter" "call_sessions_count" {
  name           = "${var.app_identifier}-CallSessionsCount"
  pattern        = "{ $.${var.global_call_sessions_count_log_key} = * }"
  log_group_name = aws_cloudwatch_log_group.app.name

  metric_transformation {
    name      = "${var.app_identifier}-CallSessionsCount"
    namespace = "Somleng"
    value     = "$.${var.global_call_sessions_count_log_key}"
    dimensions = {
      Cluster = "$.log-group-stream[0]"
    }
    unit = "Count"
  }

  depends_on = [null_resource.log_transformer]
}

resource "aws_cloudwatch_log_metric_filter" "outbound_calls_queue" {
  name           = "${var.app_identifier}-OutboundCallsQueueCount"
  pattern        = "{ $.${var.global_call_sessions_count_log_key} = * }"
  log_group_name = aws_cloudwatch_log_group.app.name

  metric_transformation {
    name      = "${var.app_identifier}-OutboundCallsQueueCount"
    namespace = "Somleng"
    value     = "$.${var.global_call_sessions_count_log_key}"
    dimensions = {
      Cluster = "$.log-group-stream[0]"
    }
    unit = "Count"
  }

  depends_on = [null_resource.log_transformer]
}

# https://github.com/hashicorp/terraform-provider-aws/issues/40780
# Note that we need to also manually set the value
# Enable metric filter on transformed logs = true
# using the AWS console

resource "null_resource" "log_transformer" {
  triggers = {
    replace = local.log_transformer_command
  }

  provisioner "local-exec" {
    when    = create
    command = local.log_transformer_command
  }
}

locals {
  log_transformer_command = "aws logs put-transformer --region ${var.region.aws_region} --cli-input-json '${jsonencode(
    {
      logGroupIdentifier = aws_cloudwatch_log_group.app.name,
      transformerConfig = [
        {
          parseJSON = {}
        },
        {
          copyValue = {
            entries = [
              {
                source            = "@logGroupName",
                target            = "log-group-name",
                overwriteIfExists = false
              },
              {
                source            = "@logGroupStream",
                target            = "log-group-stream",
                overwriteIfExists = false
              }
            ]
          }
        },
        {
          splitString = {
            entries = [
              {
                source    = "log-group-stream",
                delimiter = "/"
              }
            ]
          }
        }
      ]
    }
  )}'"
}
