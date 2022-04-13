class PhoneNumberPolicy < ApplicationPolicy
  def index?
    true
  end

  def update?
    super && !record.assigned?
  end

  def release?
    manage? && record.may_release?
  end

  def manage?
    carrier_admin?
  end
end
