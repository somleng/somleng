class Api::PhoneCallsController < Api::BaseController
  def create
    super
    OutboundCallJob.perform_later(resource) if resource.persisted?
  end

  private

  def association_chain
    current_account.phone_calls
  end

  def resource_location
    api_twilio_account_call_url(current_account, resource)
  end

  def permitted_params
    params.permit("To", "From", "Url", "Method", "StatusCallback", "StatusCallbackMethod")
  end
end
