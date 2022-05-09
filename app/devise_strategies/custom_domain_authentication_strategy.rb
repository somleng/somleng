require "devise/strategies/authenticatable"

class CustomDomainAuthenticationStrategy < Devise::Strategies::DatabaseAuthenticatable
  def authenticate!
    resource = mapping.to.find_for_database_authentication(authentication_hash)
    carrier_from_domain = Carrier.from_domain(host: request.hostname, type: :dashboard)

    return success!(resource) if carrier_from_domain.blank?
    return success!(resource) if carrier_from_domain == resource.carrier

    fail!("Invalid email or password")
  end
end
