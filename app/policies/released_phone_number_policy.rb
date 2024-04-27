class ReleasedPhoneNumberPolicy < ApplicationPolicy
  def read?
    account_admin?
  end
end
