class AccountPolicy < ApplicationPolicy
  def index?
    read?
  end

  def read?
    user.current_organization.carrier?
  end

  def show_auth_token?
    read? && record.carrier_managed?
  end

  def manage?
    carrier_admin?
  end

  def destroy?
    super && record.account_memberships.empty?
  end
end
