require "devise/strategies/authenticatable"

class CustomDomainAuthenticationStrategy < Devise::Strategies::DatabaseAuthenticatable
  def authenticate!
    resource = mapping.to.find_for_database_authentication(authentication_hash)

    return success!(resource) if CustomDomainAuthorizationPolicy.new(
      carrier: resource.carrier,
      host: request.hostname,
      context: :dashboard
    ).authorized?

    fail!("Invalid email or password")
  end
end
