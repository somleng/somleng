class PhoneNumberPolicy < ApplicationPolicy
  def index?
    managing_carrier?
  end

  def bulk_destroy?
    manage?
  end

  def manage?
    carrier_admin?
  end
end
