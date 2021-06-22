class PhoneNumberPolicy < ApplicationPolicy
  def index?
    true
  end

  def manage?
    carrier_admin?
  end
end
