class TariffSchedulePolicy < ApplicationPolicy
  def manage?
    carrier_admin?
  end
end
