class AccountSettingsPolicy < ApplicationPolicy
  def show?
    manage?
  end

  def manage?
    user.current_organization.account?
  end
end
