class AccountPolicy < ApplicationPolicy
  def show_auth_token?
    false
  end
end
