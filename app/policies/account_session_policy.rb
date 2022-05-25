class AccountSessionPolicy < ApplicationPolicy
  def manage?
    managing_account? && user.account_memberships.size > 1
  end
end
