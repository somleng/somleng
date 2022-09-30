module Utils
  def self.deep_merge(hash1, hash2)
    hash1.stringify_keys.deep_merge(hash2.stringify_keys)
  end

  # https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/
  # Full jitter
  def self.exponential_backoff_delay(number_of_attempts:, max_retry_period:, max_attempts:)
    exponential_delay = (max_retry_period.seconds**(number_of_attempts / max_attempts.to_f))
    SecureRandom.random_number(0..exponential_delay)
  end
end
