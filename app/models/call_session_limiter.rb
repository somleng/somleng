class CallSessionLimiter
  attr_reader :session_counters

  def initialize(**options)
    @session_counters = options.fetch(:session_counters) do
      SomlengRegion::Region.all.each_with_object({}) do |region, result|
        result[region.alias.to_sym] = SimpleCounter.new(
          key: options.fetch(:key) { "#{options.fetch(:namespace, :phone_call_sessions)}:#{region.alias}" },
          expiry: options.fetch(:expiry) { 30.minutes },
          limit: options.fetch(:limit) { options.fetch(:limit_per_capacity_unit) * options.fetch(:call_service_capacity) { CallServiceCapacity.current_for(region.alias) } }
        )
      end
    end
  end

  def add_session_to(region, scope:)
    session_counter_for(region).increment(scope:)
  end

  def remove_session_from(region, scope:)
    session_counter_for(region).decrement(scope:)
  end

  def session_count_for(region, scope:)
    session_counter_for(region).count(scope:)
  end

  def exceeds_limit?(region, scope:)
    session_counter_for(region).exceeds_limit?(scope:)
  end

  private

  def session_counter_for(region)
    session_counters.fetch(region.to_sym)
  end
end
