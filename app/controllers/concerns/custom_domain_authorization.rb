module CustomDomainAuthorization
  extend ActiveSupport::Concern

  included do
    before_action :authorize_custom_domain!
  end

  private

  def authorize_custom_domain!
    return if CustomDomainAuthorizationPolicy.new(
      carrier: authorized_carrier,
      host: request.hostname,
      context: custom_domain_context
    ).authorized?

    deny_access!
  end

  def deny_access!
    head(:unauthorized)
  end
end
