require "devise/strategies/authenticatable"

class CustomDomainAuthenticationStrategy < Devise::Strategies::TwoFactorAuthenticatable
  private

  def authentication_hash
    return super unless app_request.custom_domain_request?

    custom_domain = app_request.find_custom_domain!(:dashboard)
    result = super
    result.key?(:email) ? result.merge(carrier_id: custom_domain.carrier_id) : result
  end

  def app_request
    @app_request ||= AppRequest.new(request)
  end
end
