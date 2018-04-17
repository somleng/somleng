# frozen_string_literal: true

class StatusCallbackNotifierJob < ApplicationJob
  DEFAULT_STATUS_CALLBACK_METHOD = 'POST'

  attr_accessor :phone_call

  def perform(phone_call_id)
    self.phone_call = PhoneCall.find(phone_call_id)
    twilio_http_request.execute!(http_request)
  end

  private

  def twilio_http_request
    @twilio_http_request ||= TwilioHttpClientRequest.new
  end

  def http_request
    @http_request ||= Somleng::TwilioHttpClient::Request.new(
      request_url: phone_call.status_callback_url,
      request_method: phone_call.status_callback_method || DEFAULT_STATUS_CALLBACK_METHOD,
      account_sid: phone_call.account_sid,
      auth_token: phone_call.account_auth_token,
      call_from: phone_call.from,
      call_to: phone_call.to,
      call_sid: phone_call.sid,
      call_direction: phone_call.direction,
      call_status: phone_call.twilio_status,
      api_version: phone_call.api_version,
      body: {
        'CallDuration' => phone_call.duration.to_i
      }
    )
  end
end
