class PhoneCallSessionLimiter
  class SessionLimitExceededError < StandardError; end
  attr_reader :backend, :session_counters

  def initialize(**options)
    @backend = options.fetch(:backend) { AppSettings.redis }
    @session_counters = options.fetch(:session_counters) do
      SomlengRegion::Region.all.each_with_object({}) do |region, result|
        result[region.alias.to_sym] = SimpleCounter.new(
          key: "phone_call_sessions:#{region.alias}",
          limit: options.fetch(:limit) { AppSettings.fetch(:phone_call_sessions_limit) * current_capacity_for(region.alias) },
          backend:
        )
      end
    end
  end

  def add_session_to!(region)
    session_counter_for(region).increment!
  rescue SimpleCounter::LimitExceededError => e
    raise(SessionLimitExceededError, e.message)
  end

  def add_session_to(region)
    session_counter_for(region).increment
  end

  def remove_session_from(region)
    session_counter_for(region).decrement
  end

  def current_capacity_for(region)
    backend.with do |connection|
      connection.exists?(capacity_key(region)) ? connection.get(capacity_key(region)).to_i : 1
    end
  end

  def set_capacity_for(region, capacity:)
    backend.with do |connection|
      connection.set(capacity_key(region), capacity.to_i)
    end
  end

  def session_counter_for(region)
    session_counters.fetch(region.to_sym)
  end

  private

  def capacity_key(region)
    "switch_capacity:#{region}"
  end
end
