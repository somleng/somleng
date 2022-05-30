class AccountSettingsPolicy < ApplicationPolicy
  def show?
    manage?
  end

  def update?
    super && account_owner?
  end

  def manage?
    managing_account?
  end
end
