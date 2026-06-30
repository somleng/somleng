class TariffPlanTierPolicy < ApplicationPolicy
  def read?
    managing_carrier?
  end

  def manage?
    carrier_admin?
  end
end
