class UserPolicy < ApplicationPolicy
  def destroy?
    super && user != record
  end

  def invite?
    manage?
  end

  def manage?
    user.owner?
  end
end
