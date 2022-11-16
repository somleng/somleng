class PhoneNumberConfigurationPolicy < ApplicationPolicy
  def manage?
    account_admin? || carrier_managed?
  end

  private

  def carrier_managed?
    carrier_admin? && managing_phone_number? && record.account&.carrier_managed?
  end

  def managing_phone_number?
    user.carrier == record.managed_by_carrier
  end
end
