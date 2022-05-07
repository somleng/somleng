class CustomDomainPolicy < ApplicationPolicy
  def verify?
    manage? && user.carrier.custom_domains.where(verified_at: nil).any?
  end

  def manage?
    user.current_organization.carrier? && carrier_owner?
  end
end
