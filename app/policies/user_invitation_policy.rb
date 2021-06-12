class UserInvitationPolicy < ApplicationPolicy
  def update?
    manage_record?
  end

  private

  def manage_record?
    return false if record.accepted_or_not_invited?
    return carrier_account_users.exists?(record.id) || carrier_users.exists?(record.id) if carrier_owner?
    return carrier_account_users.exists?(record.id) if carrier_admin?

    account_users if account_owner?
  end

  def carrier_account_users
    user.carrier.account_users
  end

  def carrier_users
    user.carrier.users
  end

  def account_users
    user.current_account_membership.account.users
  end
end
