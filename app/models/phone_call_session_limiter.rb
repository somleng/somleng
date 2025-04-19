class PhoneCallSessionLimiter
  class SessionLimitExceededError < StandardError; end

  DEFAULT_SESSIONS_COUNT_KEY = "phone_call_sessions".freeze
  DEFAULT_CAPACITY_KEY = "switch_capacity".freeze

  attr_reader :backend, :session_counters

  def initialize(**options)
    @backend = options.fetch(:backend) { AppSettings.redis }
    @session_counters = options.fetch(:session_counters) do
      SomlengRegion::Region.all.each_with_object({}) do |region, result|
        result[region.alias.to_sym] = SimpleCounter.new(
          key: "#{DEFAULT_SESSIONS_COUNT_KEY}:#{region.alias}",
          limit: options.fetch(:limit) { AppSettings.fetch(:phone_call_sessions_limit) },
          backend:
        )
      end
    end
  end

  def add_session_to!(session_counter_name)
    session_counter_for(session_counter_name).increment!
  rescue SimpleCounter::LimitExceededError => e
    raise(SessionLimitExceededError, e.message)
  end

  def add_session_to(session_counter_name)
    session_counter_for(session_counter_name).increment
  end

  def remove_session_from(session_counter_name)
    session_counter_for(session_counter_name).decrement
  end

  def current_capacity
    backend.with do |connection|
      [ connection.get(capacity_key).to_i, 1 ].max
    end
  end

  def session_counter_for(name)
    session_counters.fetch(name.to_sym)
  end
end
