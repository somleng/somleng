class TariffSchedulePolicy < ApplicationPolicy
  def read?
    managing_carrier?
  end

  def manage?
    carrier_admin?
  end

  def destroy?
    manage? && record.plan_tiers.empty?
  end
end
