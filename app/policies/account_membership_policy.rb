class AccountMembershipPolicy < ApplicationPolicy
  def destroy?
    super && !record.user.accepted_or_not_invited?
  end
end
