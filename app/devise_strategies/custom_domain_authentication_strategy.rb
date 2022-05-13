require "devise/strategies/authenticatable"

class CustomDomainAuthenticationStrategy < Devise::Strategies::TwoFactorAuthenticatable
  private

  def authentication_hash
    return super unless custom_domain_request.custom_domain_request?

    custom_domain = custom_domain_request.find_custom_domain!(:dashboard)
    super.merge(carrier_id: custom_domain.carrier_id)
  end

  def custom_domain_request
    @custom_domain_request ||= CustomDomainRequest.new(request)
  end
end
