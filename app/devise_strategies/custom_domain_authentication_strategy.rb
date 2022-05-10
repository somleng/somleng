require "devise/strategies/authenticatable"

class CustomDomainAuthenticationStrategy < Devise::Strategies::DatabaseAuthenticatable
  def authenticate!
    resource = mapping.to.find_for_database_authentication(authentication_hash)

    return pass if CustomDomainAuthorizationPolicy.new(
      carrier: resource.carrier,
      host: request.hostname,
      context: :dashboard
    ).authorized?

    fail!(:not_found_in_database)
  end
end
