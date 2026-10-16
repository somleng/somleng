class CarrierAPIKeyPolicy < ApplicationPolicy
  def read?
    manage?
  end

  def destroy?
    super && record.active?
  end

  def manage?
    carrier_admin?
  end
end
