class TariffPackageWizardPolicy < ApplicationPolicy
  def manage?
    carrier_admin?
  end
end
