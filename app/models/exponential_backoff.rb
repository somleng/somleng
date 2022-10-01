class ExponentialBackoff
  DEFAULT_MAX_RETRY_PERIOD = 12.hours
  DEFAULT_MAX_ATTEMPTS = 50

  attr_reader :max_retry_period, :max_attempts, :random_number_generator

  def initialize(options = {})
    @max_retry_period = options.fetch(:max_retry_period, DEFAULT_MAX_RETRY_PERIOD)
    @max_attempts = options.fetch(:max_attempts, DEFAULT_MAX_ATTEMPTS)
    @random_number_generator = options.fetch(:random_number_generator) do
      ->(range) { SecureRandom.random_number(range) }
    end
  end

  # https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/
  # Full jitter
  def delay(attempt:)
    random_number_generator.call(0..calculate_delay(attempt:))
  end

  def max_total_delay
    (1..max_attempts).sum { |attempt| calculate_delay(attempt:) }
  end

  private

  def calculate_delay(attempt:)
    max_retry_period.seconds**(attempt / max_attempts.to_f)
  end
end
