class AccountPolicy < ApplicationPolicy
  def destroy?
    super && record&.customer?
  end
end
