class TariffBundlePolicy < ApplicationPolicy
  def manage?
    carrier_admin?
  end
end
