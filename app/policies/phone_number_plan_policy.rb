class PhoneNumberPlanPolicy < ApplicationPolicy
  def index?
    carrier_admin?
  end

  def create?
    account_admin?
  end
end
