class TariffBundleWizardPolicy < ApplicationPolicy
  def manage?
    carrier_admin?
  end
end
