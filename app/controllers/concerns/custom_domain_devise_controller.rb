module CustomDomainDeviseController
  extend ActiveSupport::Concern

  def resource_params
    return super unless app_request.custom_domain_request?

    custom_domain = app_request.find_custom_domain!(:dashboard)
    result = super
    result.key?(:email) ? result.merge(carrier_id: custom_domain.carrier_id) : result
  end
end
