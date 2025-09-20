class GlobalCallSessionLimiter < CallSessionLimiter
  attr_reader :scope

  def initialize(**options)
    super(limit_per_capacity_unit: AppSettings.fetch(:global_call_sessions_limit), **options)
    @scope = options.fetch(:scope, :global)
  end

  def add_session_to(*, **)
    super(*, scope:)
  end

  def remove_session_from(*, **)
    super(*, scope:)
  end

  def session_count_for(*, **)
    super(*, scope:)
  end

  def exceeds_limit?(*, **)
    super(*, scope:)
  end
end
