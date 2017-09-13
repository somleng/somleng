class Api::Admin::PhoneCallsController < Api::Admin::BaseController
  self.responder = Api::Admin::PhoneCallsResponder

  private

  def resource_location
    api_admin_phone_call_url(resource)
  end

  def permission_name
    :manage_inbound_phone_calls
  end

  def association_chain
    PhoneCall
  end

  def save_resource
    resource.initiate_inbound_call
  end

  def permitted_params
    params.permit("To", "From", "ExternalSid", "Variables" => {})
  end
end
