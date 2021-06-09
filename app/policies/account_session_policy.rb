class AccountSessionPolicy < ApplicationPolicy
  def manage?
    user.current_organization.blank? || user.account_memberships.size > 1
  end
end
