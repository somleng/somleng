class PhoneNumberConfigurationPolicy < ApplicationPolicy
  def manage?
    account_admin? || carrier_managed?
  end

  private

  def carrier_managed?
    carrier_admin? && manages_record? && record.account&.carrier_managed?
  end

  def manages_record?
    user.carrier == record.managing_carrier
  end
end
