class SimpleCounter
  class LimitExceededError < StandardError; end

  attr_reader :key, :limit, :backend

  def initialize(key:, limit: nil, **options)
    @key = key
    @limit = limit
    @backend = options.fetch(:backend) { AppSettings.redis }
  end

  def increment
    backend.with { _1.incr(key) }
  end

  def increment!
    raise(LimitExceededError) if limit.present? && count >= limit

    increment
  end

  def decrement
    backend.with { _1.decr(key) }
  end

  def count
    backend.with { _1.get(key).to_i }
  end
end
