class AvailablePhoneNumberPolicy < ApplicationPolicy
  def read?
    account_admin?
  end
end
