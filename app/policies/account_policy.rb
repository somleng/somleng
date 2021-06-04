class AccountPolicy < ApplicationPolicy
  def index?
    manage?
  end

  def manage?
    user.current_organization.carrier?
  end

  def destroy?
    super && record.account_memberships.empty?
  end
end
