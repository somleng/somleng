# Reduce the number of requests against SQS
# https://github.com/ruby-shoryuken/shoryuken/wiki/Shoryuken-options#cache_visibility_timeout
Shoryuken.cache_visibility_timeout = true

Shoryuken.configure_server do |config|
  config.on(:startup) do
    @server_pid = OkComputer::RackServer.run!
  end

  config.on(:shutdown) do
    if @server_pid.present?
      Process.kill("TERM", @server_pid)
      Process.wait(@server_pid)
    end
  end

  config.default_worker_options["auto_visibility_timeout"] = true

  Shoryuken.default_worker_options["retry_intervals"] = lambda { |attempts|
    Utils.exponential_backoff_delay(
      number_of_attempts: attempts,
      max_retry_period: 12.hours,
      max_attempts: 10
    )
  }

  # Turn on long polling
  # https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-short-and-long-polling.html
  # https://github.com/phstc/shoryuken/wiki/Long-Polling
  config.sqs_client_receive_message_opts = { wait_time_seconds: 20 }
end
