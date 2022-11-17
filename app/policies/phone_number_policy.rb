class PhoneNumberPolicy < ApplicationPolicy
  def read?
    true
  end

  def update?
    carrier_admin? && manages_record?
  end

  def release?
    update? && record.may_release?
  end

  def manage?
    carrier_admin? && owns_record?
  end

  def create?
    carrier_admin?
  end

  private

  def owns_record?
    user.carrier == record.carrier
  end

  def manages_record?
    user.carrier == record.managing_carrier
  end
end
