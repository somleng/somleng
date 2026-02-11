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

  # `JobWrapper` is defined before initializer
  Shoryuken::ActiveJob::JobWrapper.shoryuken_options(
    retry_intervals: ->(attempts) { ExponentialBackoff.new.delay(attempt: attempts) },
    auto_visibility_timeout: true
  )

  # Turn on long polling
  # https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-short-and-long-polling.html
  # https://github.com/phstc/shoryuken/wiki/Long-Polling
  config.sqs_client_receive_message_opts = { wait_time_seconds: 20 }
end
