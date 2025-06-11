class SimpleCounter
  DECREMENT_SCRIPT = <<~LUA
    local val = redis.call('GET', KEYS[1])
    if not val then
      return 0
    end
    val = tonumber(val)
    if val > 0 then
      return redis.call('DECR', KEYS[1])
    else
      return val
    end
  LUA

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

  def decrement(scope: nil)
    key = build_key(scope)
    result, = with_expire(key) do |transaction|
      transaction.eval(DECREMENT_SCRIPT, keys: [ key ])
    end
    result
  end

  def count(scope: nil)
    backend.with { _1.get(build_key(scope)).to_i }
  end

  def exceeds_limit?(scope: nil)
    limit.present? && count(scope:) >= limit
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
