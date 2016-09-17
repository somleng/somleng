class Api::PhoneCallsController < Api::PublicController
  def create
    super
    resource.enqueue_outbound_call! if resource.persisted?
  end

  private

  def association_chain
    current_account.phone_calls
  end

  def permitted_params
    params.permit("To", "From", "Url", "Method", "StatusCallback", "StatusCallbackMethod")
  end
end
