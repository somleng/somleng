class NotifyPhoneCallStatusCallback
  attr_reader :phone_call

  def initialize(phone_call)
    @phone_call = phone_call
  end

  def call
    NotifyStatusCallback.call(
      phone_call,
      phone_call.status_callback_url,
      phone_call.status_callback_method,
      params: TwilioAPI::StatusCallbackSerializer.new(
        PhoneCallDecorator.new(phone_call)
      ).serializable_hash
    )
  end
end
