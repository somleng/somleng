class GlobalCallSessionLimiter < CallSessionLimiter
  attr_reader :scope, :log_key

  def initialize(**options)
    super(limit_per_capacity_unit: AppSettings.fetch(:global_call_sessions_limit), **options)
    @scope = options.fetch(:scope, :global)
    @log_key = options.fetch(:log_key) { AppSettings.fetch(:global_call_sessions_count_log_key) }
  end

  def add_session_to(*, **)
    result = super(*, scope:)
    log_sessions_count(result)
  end

  def remove_session_from(*, **)
    result = super(*, scope:)
    log_sessions_count(result)
  end

  def session_count_for(*, **)
    super(*, scope:)
  end

  def exceeds_limit?(*, **)
    super(*, scope:)
  end

  private

  def log_sessions_count(count)
    logger.info(JSON.generate(log_key => count))
  end
end
