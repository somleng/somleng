class TariffPlanPolicy < ApplicationPolicy
  def manage?
    carrier_admin?
  end

  def destroy?
    record.subscriptions.empty?
  end
end
