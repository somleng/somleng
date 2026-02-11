class TariffSchedulePolicy < ApplicationPolicy
  def manage?
    carrier_admin?
  end

  def destroy?
    record.plan_tiers.empty?
  end
end
