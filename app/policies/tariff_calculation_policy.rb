class TariffCalculationPolicy < ApplicationPolicy
  def manage?
    carrier_admin?
  end
end
