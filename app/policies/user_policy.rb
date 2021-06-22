class UserPolicy < ApplicationPolicy
  def read?
    user.current_organization.carrier?
  end

  def destroy?
    super && manage_record?
  end

  def update?
    destroy?
  end

  def manage?
    carrier_owner?
  end

  private

  def manage_record?
    record.id != user.id
  end
end
