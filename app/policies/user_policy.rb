class UserPolicy < ApplicationPolicy
  def read?
    user.current_organization.carrier?
  end

  def manage?
    carrier_owner?
  end
end
