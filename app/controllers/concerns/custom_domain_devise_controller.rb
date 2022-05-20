module CustomDomainDeviseController
  extend ActiveSupport::Concern

  def resource_params
    carrier_id = if app_request.custom_domain_request?
                   app_request.find_custom_domain!(:dashboard).carrier_id
                 else
                   "__missing__"
                 end

    result = super
    result.key?(:email) ? result.merge(carrier_id:) : result
  end
end
