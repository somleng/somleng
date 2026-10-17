class TwoFactorAuthenticationPolicy < ApplicationPolicy
  def create?
    !user.otp_required_for_login?
  end

  def destroy?
    manage_record?
  end

  private

  def manage_record?
    return false if user.id == record.id
    return false unless record.otp_required_for_login?
    return true if carrier_owner? && user.carrier.carrier_users.exists?(record.id)
    return true if account_owner? && user.current_account_membership.account.users.exists?(record.id)
    return true if carrier_admin? && user.carrier.account_memberships.owner.exists?(user_id: record.id)

    false
  end
end
