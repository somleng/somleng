class CarrierSettingsPolicy < ApplicationPolicy
  def show?
    manage?
  end

  def update?
    super && carrier_owner?
  end

  def manage?
    user.current_organization.carrier?
  end
end
