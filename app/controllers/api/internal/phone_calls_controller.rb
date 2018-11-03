class Api::Internal::PhoneCallsController < Api::Internal::BaseController
  self.responder = Api::Internal::PhoneCallsResponder

  private

  def resource_location
    api_internal_phone_call_url(resource)
  end

  def association_chain
    PhoneCall.all
  end

  def save_resource
    resource.initiate_inbound_call
  end

  def permitted_params
    params.permit("To", "From", "ExternalSid", "Variables" => {})
  end
end
