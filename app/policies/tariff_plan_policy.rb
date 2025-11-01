class TariffPlanPolicy < ApplicationPolicy
  def manage?
    carrier_admin?
  end
end
