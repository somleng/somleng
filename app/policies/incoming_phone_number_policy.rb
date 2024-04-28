class IncomingPhoneNumberPolicy < ApplicationPolicy
  def manage?
    record.active? && (account_admin? || carrier_managed?)
  end

  private

  def carrier_managed?
    carrier_admin? && record.carrier_managed?
  end
end
