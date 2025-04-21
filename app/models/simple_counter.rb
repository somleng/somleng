class SimpleCounter
  class LimitExceededError < StandardError; end

  attr_reader :key, :limit, :expiry, :backend

  def initialize(key:, **options)
    @key = key
    @limit = options.fetch(:limit, nil)
    @expiry = options.fetch(:expiry, nil)
    @backend = options.fetch(:backend) { AppSettings.redis }
  end

  def increment
    with_expire do |transaction|
      transaction.incr(key)
    end
  end

  def increment!
    raise(LimitExceededError) if limit.present? && count >= limit

    increment
  end

  def decrement
    with_expire do |transaction|
      transaction.decr(key)
    end
  end

  def count
    backend.with { _1.get(key).to_i }
  end

  private

  def with_expire(&)
    backend.with do |connection|
      connection.multi do |transaction|
        yield(transaction)
        transaction.expire(key, expiry) if expiry.present?
      end
    end
  end
end
