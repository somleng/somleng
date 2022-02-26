class StatusCallbackNotifierJob < ApplicationJob
  def perform(phone_call)
    NotifyStatusCallback.call(
      phone_call,
      phone_call.status_callback_url,
      phone_call.status_callback_method,
      call_params: TwilioAPI::StatusCallbackSerializer.new(PhoneCallDecorator.new(phone_call)).serializable_hash
    )
  end
end
