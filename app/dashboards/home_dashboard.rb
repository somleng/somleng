require "administrate/custom_dashboard"

class HomeDashboard < Administrate::CustomDashboard
  CALL_SESSION_LIMITER = GlobalCallSessionLimiter.new

  def self.resource_name(_opts)
    "Home"
  end

  def current_call_sessions
    SomlengRegion::Region.all.each_with_object({}) do |region, result|
      result[region.alias] = CALL_SESSION_LIMITER.session_count_for(region.alias)
    end
  end
end
