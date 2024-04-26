class PhoneNumberPlanPolicy < ApplicationPolicy
  def index?
    carrier_admin?
  end

  def create?
    carrier_admin? || account_admin?
  end
end
