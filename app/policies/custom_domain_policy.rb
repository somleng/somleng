class CustomDomainPolicy < ApplicationPolicy
  def verify?
    manage? && custom_domains.unverified.any?
  end

  def regenerate?
    manage? && CustomDomain.wrap(user.carrier.custom_domain(:mail)).expired?
  end

  def destroy?
    super && custom_domains.any?
  end

  def manage?
    user.current_organization.carrier? && carrier_owner?
  end

  private

  def custom_domains
    user.carrier.custom_domains
  end
end
