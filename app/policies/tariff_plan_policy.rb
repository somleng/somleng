class TariffPlanPolicy < ApplicationPolicy
  def manage?
    carrier_admin?
  end

  def destroy?
    manage? && record.subscriptions.empty?
  end
end
