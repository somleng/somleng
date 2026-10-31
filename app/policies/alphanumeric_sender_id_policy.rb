class AlphanumericSenderIDPolicy < ApplicationPolicy
  def index?
    true
  end

  def destroy?
    return false unless super

    return false if managing_carrier? && record.account.customer_managed?
    true
  end

  def manage?
    carrier_admin? || account_admin?
  end
end
