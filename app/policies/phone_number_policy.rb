class PhoneNumberPolicy < ApplicationPolicy
  def index?
    true
  end

  def release?
    manage? && record.assigned?
  end

  def bulk_destroy?
    manage?
  end

  def manage?
    carrier_admin?
  end
end
