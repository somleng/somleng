class AccountMembershipPolicy < ApplicationPolicy
  def destroy?
    super && !record.user.accepted_or_not_invited?
  end

  def manage?
    carrier_admin? || account_owner?
  end

  def update?
    account_owner?
  end
end
