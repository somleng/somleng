require "devise/strategies/authenticatable"

class CustomDomainAuthenticationStrategy < Devise::Strategies::TwoFactorAuthenticatable
  private

  def authentication_hash
    return super unless custom_domain_request.custom_domain_request?

    carrier = Carrier.from_domain(host: custom_domain_request.custom_domain_hostname, type: :dashboard)
    super.merge(carrier_id: carrier.id)
  end

  def custom_domain_request
    @custom_domain_request ||= CustomDomainRequest.new(request)
  end
end
