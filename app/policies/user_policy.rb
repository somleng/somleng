class UserPolicy < ApplicationPolicy
  def destroy?
    super && user != record
  end
end
