module Utils
  def self.deep_merge(hash1, hash2)
    hash1.stringify_keys.deep_merge(hash2.stringify_keys)
  end

  def self.exponential_backoff_delay(number_of_attempts:, max_retry_period:, max_attempts:)
    (max_retry_period.seconds**(number_of_attempts / max_attempts.to_f)).to_i
  end
end
