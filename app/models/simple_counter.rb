class SimpleCounter
  attr_reader :tag, :key, :limit, :expiry, :backend

  def initialize(**options)
    @key = options.fetch(:key)
    @tag = "{counter:#{key}}"
    @limit = options.fetch(:limit, nil)
    @expiry = options.fetch(:expiry, 5.minutes)
    @backend = options.fetch(:backend) { AppSettings.redis }
  end

  def increment(scope: nil)
    backend.with do |connection|
      connection.zadd(build_key(scope), Time.now.to_f, SecureRandom.uuid)
    end
  end

  def decrement(scope: nil)
    backend.with do |connection|
      connection.zpopmax(build_key(scope))
    end
  end

  def count(scope: nil)
    key = build_key(scope)

    backend.with do |connection|
      connection.multi do |transaction|
        transaction.zremrangebyscore(key, "-inf", (Time.now - expiry).to_f)
        transaction.zcard(key)
      end.last
    end
  end

  def exceeds_limit?(scope: nil)
    limit.present? && count(scope:) >= limit
  end

  private

  def build_key(scope)
    [ tag, scope, key ].compact.join(":")
  end
end
