class AccountMembershipPolicy < ApplicationPolicy
  def destroy?
    super && manage_record?
  end

  def update?
    destroy?
  end

  def manage?
    account_owner?
  end

  def read?
    managing_account?
  end

  private

  def manage_record?
    record.user_id != user.id
  end
end
