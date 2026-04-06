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

  depends_on = [aws_cloudwatch_log_transformer.log_transformer]
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

  depends_on = [aws_cloudwatch_log_transformer.log_transformer]
}

resource "aws_cloudwatch_log_transformer" "log_transformer" {
  log_group_arn = aws_cloudwatch_log_group.app.arn
  transformer_config {
    parse_json {}
  }

  transformer_config {
    copy_value {
      entry {
        source              = "@logGroupName"
        target              = "log-group-name"
        overwrite_if_exists = false
      }
      entry {
        source              = "@logGroupStream"
        target              = "log-group-stream"
        overwrite_if_exists = false
      }
    }
  }

  transformer_config {
    split_string {
      entry {
        source    = "log-group-stream"
        delimiter = "/"
      }
    }
  }
}
