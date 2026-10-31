class AlphanumericSenderIDPolicy < ApplicationPolicy
  def index?
    true
  end

  def create?
    true
  end

  def destroy?
    true
  end
end
