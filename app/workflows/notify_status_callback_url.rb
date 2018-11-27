class NotifyStatusCallbackUrl < ApplicationWorkflow
  DEFAULT_STATUS_CALLBACK_METHOD = "POST".freeze

  def call
    phone_call = options.fetch(:phone_call)
    phone_call_attributes = PhoneCallSerializer.new(phone_call).as_json

    TwilioHttpClientRequest.new.execute!(
      Somleng::TwilioHttpClient::Request.new(
        request_url: phone_call.status_callback_url,
        request_method: phone_call.status_callback_method || DEFAULT_STATUS_CALLBACK_METHOD,
        auth_token: phone_call.account.auth_token,
        account_sid: phone_call_attributes.fetch("account_sid"),
        call_from: phone_call_attributes.fetch("from"),
        call_to: phone_call_attributes.fetch("to"),
        call_sid: phone_call_attributes.fetch("sid"),
        call_direction: phone_call_attributes.fetch("direction"),
        call_status: phone_call_attributes.fetch("status"),
        api_version: phone_call_attributes.fetch("api_version"),
        body: {
          "CallDuration" => phone_call_attributes.fetch("duration")
        }
      )
    )
  end
end
