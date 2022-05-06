class CustomDomainPolicy < ApplicationPolicy
  def manage?
    user.current_organization.carrier? && carrier_owner?
  end
end
