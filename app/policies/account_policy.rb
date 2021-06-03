class AccountPolicy < ApplicationPolicy
  def show_auth_token?
    false
  end

  def index?
    manage?
  end

  def manage?
    user.current_organization.carrier?
  end
end
