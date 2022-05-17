class TwoFactorAuthenticationPolicy < ApplicationPolicy
  def create?
    true
  end

  def destroy?
    manage_record?
  end

  private

  def manage_record?
    return false if user.id == record.id
    return false unless record.otp_required_for_login?
    return carrier_users.exists?(record.id) if carrier_owner?

    account_users.exists?(record.id) if account_owner?
  end

  def carrier_users
    user.carrier.carrier_users
  end

  def account_users
    user.current_account_membership.account.users
  end
end
