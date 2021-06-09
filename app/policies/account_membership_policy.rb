class AccountMembershipPolicy < ApplicationPolicy
  def destroy?
    carrier_admin_destroy? || account_owner_destroy?
  end

  def manage?
    carrier_admin? || account_managed?
  end

  def update?
    account_managed?
  end

  def account_managed?
    account_owner?
  end

  private

  def carrier_admin_destroy?
    carrier_admin? && !record.user.accepted_or_not_invited?
  end

  def account_owner_destroy?
    account_owner? && record.user_id != user.id
  end
end
