class TariffPlanTierPolicy < ApplicationPolicy
  def manage?
    carrier_admin?
  end
end
