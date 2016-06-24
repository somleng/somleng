class Api::PhoneCallsController < Api::BaseController
  private

  def association_chain
    current_account.phone_calls
  end

  def permitted_params
    params.permit("To", "From", "Url", "Method", "StatusCallbackUrl", "StatusCallbackMethod")
  end
end
