class PhoneNumberPolicy < ApplicationPolicy
  def read?
    true
  end

  def update?
    manages_record?
  end

  def release?
    update? && record.may_release?
  end

  def manage?
    owns_record?
  end

  private

  def owns_record?
    carrier_admin? && user.carrier == record.carrier
  end

  def manages_record?
    carrier_admin? && user.carrier == record.managing_carrier
  end
end
