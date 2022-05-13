require "devise/strategies/authenticatable"

class CustomDomainAuthenticationStrategy < Devise::Strategies::TwoFactorAuthenticatable
  def authenticate!
    binding.pry
    resource = mapping.to.find_for_database_authentication(authentication_hash)

    return super if resource.blank?
    return super if CustomDomainAuthorizationPolicy.new(
      carrier: resource.carrier,
      host: request.hostname,
      context: :dashboard
    ).authorized?

    fail!(:not_found_in_database)
  end

  private

  def authentication_hash
    carrier = Carrier.from_domain(host: request.hostname, type: :dashboard)
    carrier.present? ? super.merge(carrer_id: carrier.id) : super
  end
end
