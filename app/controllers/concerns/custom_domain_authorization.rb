module CustomDomainAuthorization
  extend ActiveSupport::Concern

  included do
    append_before_action :authorize_custom_domain!
  end

  private

  def authorize_custom_domain!
    return if carrier_from_domain.blank?
    return if authorized_carrier == carrier_from_domain

    deny_access!
  end

  def carrier_from_domain
    @carrier_from_domain ||= Carrier.from_domain(
      host: request.host,
      type: custom_domain_scope
    )
  end

  def deny_access!
    head(:unauthorized)
  end
end
