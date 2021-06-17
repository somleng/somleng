class PhoneNumberConfigurationPolicy < ApplicationPolicy
  def manage?
    account_admin? || carrier_managed?
  end

  private

  def carrier_managed?
    carrier_admin? && record.account&.carrier_managed?
  end
end
