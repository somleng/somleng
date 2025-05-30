require "administrate/custom_dashboard"

class HomeDashboard < Administrate::CustomDashboard
  def self.resource_name(_opts)
    "Home"
  end

  def current_call_sessions
    per_region { GlobalCallSessionLimiter.new.session_count_for(_1) }
  end

  def call_service_capacity
    per_region { CallServiceCapacity.current_for(_1) }
  end

  def global_call_sessions_limit
    AppSettings.fetch(:global_call_sessions_limit)
  end

  def account_call_sessions_limit
    AppSettings.fetch(:account_call_sessions_limit)
  end

  private

  def per_region
    SomlengRegion::Region.all.each_with_object({}) do |region, result|
      result[region.alias] = yield(region.alias)
    end
  end
end
