[
  {
    "name": "worker",
    "image": "${app_image}:latest",
    "logConfiguration": {
      "logDriver": "awslogs",
       "options": {
         "awslogs-group": "${worker_logs_group}",
         "awslogs-region": "${logs_group_region}",
         "awslogs-stream-prefix": "${app_environment}"
       }
    },
    "command": ["bundle", "exec", "shoryuken", "-R", "-C", "config/shoryuken.yml"],
    "startTimeout": 120,
    "healthCheck": {
      "command": [ "CMD-SHELL", "wget --server-response --spider --quiet http://localhost:3000/health_checks 2>&1 | grep '200 OK' > /dev/null" ],
      "interval": 10,
      "retries": 10,
      "timeout": 5
    },
    "essential": true,
    "secrets": [
      {
        "name": "RAILS_MASTER_KEY",
        "valueFrom": "${rails_master_key_parameter_arn}"
      },
      {
        "name": "DATABASE_PASSWORD",
        "valueFrom": "${database_password_parameter_arn}"
      },
      {
        "name": "SERVICES_PASSWORD",
        "valueFrom": "${services_password_parameter_arn}"
      }
    ],
    "environment": [
      {
        "name": "RAILS_ENV",
        "value": "${app_environment}"
      },
      {
        "name": "RACK_ENV",
        "value": "${app_environment}"
      },
      {
        "name": "AWS_SQS_HIGH_PRIORITY_QUEUE_NAME",
        "value": "${aws_sqs_high_priority_queue_name}"
      },
      {
        "name": "AWS_SQS_DEFAULT_QUEUE_NAME",
        "value": "${aws_sqs_default_queue_name}"
      },
      {
        "name": "AWS_SQS_LOW_PRIORITY_QUEUE_NAME",
        "value": "${aws_sqs_low_priority_queue_name}"
      },
      {
        "name": "AWS_SQS_SCHEDULER_QUEUE_NAME",
        "value": "${aws_sqs_scheduler_queue_name}"
      },
      {
        "name": "AWS_DEFAULT_REGION",
        "value": "${region}"
      },
      {
        "name": "AWS_SES_REGION",
        "value": "${aws_ses_region}"
      },
      {
        "name": "DATABASE_NAME",
        "value": "${database_name}"
      },
      {
        "name": "DATABASE_USERNAME",
        "value": "${database_username}"
      },
      {
        "name": "DATABASE_HOST",
        "value": "${database_host}"
      },
      {
        "name": "DATABASE_PORT",
        "value": "${database_port}"
      },
      {
        "name": "DB_POOL",
        "value": "${db_pool}"
      },
      {
        "name": "RAILS_LOG_TO_STDOUT",
        "value": "true"
      },
      {
        "name": "UPLOADS_BUCKET",
        "value": "${uploads_bucket}"
      },
      {
        "name": "SWITCH_SERVICES_QUEUE_URL",
        "value": "${switch_services_queue_url}"
      },
      {
        "name": "RAW_RECORDINGS_BUCKET",
        "value": "${raw_recordings_bucket_name}"
      }
    ]
  }
]
