class UserPolicy < ApplicationPolicy
  def index?
    user.current_organization.carrier?
  end

  def destroy?
    super && user != record
  end

  def invite?
    manage?
  end

  def manage?
    carrier_owner?
  end
end
