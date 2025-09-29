resource "aws_cloudwatch_log_group" "app" {
  name              = var.app_identifier
  retention_in_days = 7
}

resource "aws_cloudwatch_log_metric_filter" "outbound_calls_queue" {
  name                      = "${var.app_identifier}-OutboundCallsQueue"
  log_group_name            = aws_cloudwatch_log_group.app.name
  pattern                   = "{ $.outbound_calls_queue_metrics.count = * }"
  apply_on_transformed_logs = true

  metric_transformation {
    name      = "${var.app_identifier}-OutboundCallsQueueCount"
    namespace = "Somleng"
    value     = "$.outbound_calls_queue_metrics.count"
    unit      = "Count"
    dimensions = {
      Region = "$.outbound_calls_queue_metrics.queue"
    }
  }

  depends_on = [null_resource.log_transformer]
}

resource "aws_cloudwatch_log_metric_filter" "call_service_capacity" {
  name                      = "${var.app_identifier}-CallServiceCapacity"
  log_group_name            = aws_cloudwatch_log_group.app.name
  pattern                   = "{ $.call_service_capacity.capacity = * }"
  apply_on_transformed_logs = true

  metric_transformation {
    name      = "${var.app_identifier}-CallServiceCapacity"
    namespace = "Somleng"
    value     = "$.call_service_capacity.capacity"
    unit      = "Count"
    dimensions = {
      Region = "$.call_service_capacity.region"
    }
  }

  depends_on = [null_resource.log_transformer]
}

# https://github.com/hashicorp/terraform-provider-aws/issues/40780

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
