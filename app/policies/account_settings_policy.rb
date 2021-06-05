class AccountSettingsPolicy < ApplicationPolicy
  def show?
    manage?
  end

  def update?
    super && account_owner?
  end

  def manage?
    user.current_organization.account?
  end
end
