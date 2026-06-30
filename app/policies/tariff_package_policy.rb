class TariffPackagePolicy < ApplicationPolicy
  def read?
    managing_carrier?
  end

  def manage?
    carrier_admin?
  end
end
