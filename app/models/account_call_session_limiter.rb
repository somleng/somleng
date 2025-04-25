class AccountCallSessionLimiter < CallSessionLimiter
  def initialize(**)
    super(limit_per_capacity_unit: AppSettings.fetch(:account_call_sessions_limit), **)
  end

  def add_session_to!(*, scope:)
    super(*, scope: scope_key(scope))
  end

  def add_session_to(*, scope:)
    super(*, scope: scope_key(scope))
  end

  def remove_session_from(*, scope:)
    super(*, scope: scope_key(scope))
  end

  def session_count_for(*, scope:)
    super(*, scope: scope_key(scope))
  end

  private

  def scope_key(scope)
    "account:#{scope}"
  end
end
