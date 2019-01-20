class NotifyStatusCallbackUrl < ApplicationWorkflow
  DEFAULT_STATUS_CALLBACK_METHOD = "POST".freeze

  attr_accessor :phone_call

  def initialize(phone_call)
    self.phone_call = phone_call
  end

  def call
    send_webhook_notification!
  end

  private

  def send_webhook_notification!
    params = API::PhoneCallSerializer.new(phone_call).as_json
    Somleng::TwilioHttpClient::Request.new(
      request_url: phone_call.status_callback_url,
      request_method: phone_call.status_callback_method || DEFAULT_STATUS_CALLBACK_METHOD,
      auth_token: phone_call.account.auth_token,
      account_sid: params.fetch("account_sid"),
      call_from: params.fetch("from"),
      call_to: params.fetch("to"),
      call_sid: params.fetch("sid"),
      call_direction: params.fetch("direction"),
      call_status: params.fetch("status"),
      api_version: params.fetch("api_version"),
      body: {
        "CallDuration" => params.fetch("duration")
      }
    ).execute!
  end
end
