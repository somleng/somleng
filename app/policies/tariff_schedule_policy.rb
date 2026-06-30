class TariffSchedulePolicy < ApplicationPolicy
  def manage?
    carrier_admin?
  end

  def destroy?
    manage? && record.plan_tiers.empty?
  end
end
