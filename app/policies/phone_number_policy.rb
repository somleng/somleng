class PhoneNumberPolicy < ApplicationPolicy
  def index?
    true
  end

  def bulk_destroy?
    manage?
  end

  def manage?
    carrier_admin?
  end
end
