class PhoneCallSessionLimiter
  class SessionLimitExceededError < StandardError; end

  class SessionsCounter
    class SessionLimitExceededError < StandardError; end

    attr_reader :key, :limit, :counter

    def initialize(**options)
      @key = options.fetch(:key)
      @limit = options.fetch(:limit)
      @counter = options.fetch(:counter) { SimpleCounter.new(backend: options.fetch(:backend) { AppSettings.redis }) }
    end

    def count=(value)
      counter.set(key, value.to_i)
    end

    def count
      get
    end

    def increment!
      raise(SessionLimitExceededError) if count >= limit

      counter.increment(key)
    end

    def decrement!
      counter.decrement(key)
    end

    private

    def get
      counter.get(key).to_i
    end
  end

  DEFAULT_SESSIONS_COUNT_KEY = "phone_call_sessions".freeze
  DEFAULT_CAPACITY_KEY = "switch_capacity".freeze

  attr_reader :backend, :capacity_key, :sessions_counter

  def initialize(**options)
    @capacity_key = options.fetch(:capacity_key) { "#{DEFAULT_CAPACITY_KEY}:#{options.fetch(:key)}" }
    @backend = options.fetch(:backend) { AppSettings.redis }
    @sessions_counter = options.fetch(:sessions_counter) do
      sessions_count_key = options.fetch(:sessions_count_key) { "#{DEFAULT_SESSIONS_COUNT_KEY}:#{options.fetch(:key)}" }
      sessions_limit = options.fetch(:sessions_limit) { AppSettings.fetch(:phone_call_sessions_limit) * options.fetch(:capacity) { current_capacity }  }

      SessionsCounter.new(backend:, key: sessions_count_key, limit: sessions_limit)
    end
  end

  def current_capacity=(capacity)
    backend.with do |connection|
      connection.set(capacity_key, capacity.to_i)
    end
  end

  def sessions_count=(value)
    sessions_counter.count = value
  end

  def sessions_count
    sessions_counter.count
  end

  def sessions_limit
    sessions_counter.limit
  end

  def add_session!
    sessions_counter.increment!
  rescue SessionsCounter::SessionLimitExceededError => e
    raise(SessionLimitExceededError, e.message)
  end

  def remove_session!
    sessions_counter.decrement!
  end

  def current_capacity
    backend.with do |connection|
      [ connection.get(capacity_key).to_i, 1 ].max
    end
  end
end
