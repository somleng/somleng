class TariffPlanPolicy < ApplicationPolicy
  def read?
    managing_carrier?
  end

  def manage?
    carrier_admin?
  end

  def destroy?
    manage? && record.subscriptions.empty?
  end
end
