class SimpleCounter
  class LimitExceededError < StandardError; end

  attr_reader :key, :limit, :expiry, :backend

  def initialize(**options)
    @key = options.fetch(:key, nil)
    @limit = options.fetch(:limit, nil)
    @expiry = options.fetch(:expiry, nil)
    @backend = options.fetch(:backend) { AppSettings.redis }
  end

  def increment(scope: nil)
    key = build_key(scope)
    result, = with_expire(key) do |transaction|
      transaction.incr(key)
    end
    result
  end

  def increment!(scope: nil)
    raise(LimitExceededError) if limit.present? && count(scope:) >= limit

    increment(scope:)
  end

  def decrement(scope: nil)
    key = build_key(scope)
    result, = with_expire(key) do |transaction|
      transaction.decr(key)
    end
    result
  end

  def count(scope: nil)
    backend.with { _1.get(build_key(scope)).to_i }
  end

  private

  def with_expire(key, &)
    backend.with do |connection|
      connection.multi do |transaction|
        yield(transaction)
        transaction.expire(key, expiry) if expiry.present?
      end
    end
  end

  def build_key(scope)
    [ scope, key ].compact.join(":")
  end
end
