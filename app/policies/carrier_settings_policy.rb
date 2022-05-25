class CarrierSettingsPolicy < ApplicationPolicy
  def show?
    manage?
  end

  def update?
    super && carrier_owner?
  end

  def manage?
    managing_carrier?
  end
end
