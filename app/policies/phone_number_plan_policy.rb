class PhoneNumberPlanPolicy < ApplicationPolicy
  def index?
    true
  end

  def destroy?
    manage? && record.active?
  end

  def manage?
    carrier_admin? || account_admin?
  end
end
