class AuthTokenPolicy < ApplicationPolicy
  def read?
    carrier_admin? || account_admin?
  end

  def create?
    read?
  end

  def manage?
    (carrier_admin? && record.account.carrier_managed?) || (account_owner? && record.account.customer_managed?)
  end

  def destroy?
    manage? && record.active?
  end
end
