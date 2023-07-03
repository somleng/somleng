class PhoneNumberPolicy < ApplicationPolicy
  def index?
    true
  end

  def release?
    manage? && record.may_release?
  end

  def bulk_destroy?
    manage?
  end

  def manage?
    carrier_admin?
  end
end
