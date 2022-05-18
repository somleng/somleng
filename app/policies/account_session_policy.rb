class AccountSessionPolicy < ApplicationPolicy
  def manage?
    user.account_memberships.size > 1
  end
end
