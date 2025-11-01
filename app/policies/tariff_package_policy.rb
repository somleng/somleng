class TariffPackagePolicy < ApplicationPolicy
  def manage?
    carrier_admin?
  end
end
