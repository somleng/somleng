Shoryuken.default_worker_options["auto_visibility_timeout"] = true
Shoryuken.default_worker_options["retry_intervals"] = lambda { |attempts|
  (12.hours.seconds**(attempts / 10.0)).to_i
}
ActiveJob::QueueAdapters::ShoryukenAdapter::JobWrapper.shoryuken_options(
  Shoryuken.default_worker_options.slice("auto_visibility_timeout", "retry_intervals")
)
# Turn on long polling
# https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-short-and-long-polling.html
# https://github.com/phstc/shoryuken/wiki/Long-Polling
Shoryuken.sqs_client_receive_message_opts["wait_time_seconds"] = 20
