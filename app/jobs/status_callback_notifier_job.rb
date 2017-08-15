require "somleng/twilio_http_client/request"

class StatusCallbackNotifierJob < ActiveJob::Base
  DEFAULT_STATUS_CALLBACK_METHOD = "POST"

  attr_accessor :phone_call

  def perform(phone_call_id)
    self.phone_call = PhoneCall.find(phone_call_id)
    http_request.execute!
  end

  private

  def http_request
    @http_request ||= Somleng::TwilioHttpClient::Request.new(
      :request_url => phone_call.status_callback_url,
      :request_method => phone_call.status_callback_method || DEFAULT_STATUS_CALLBACK_METHOD,
      :account_sid => phone_call.account_sid,
      :auth_token => phone_call.account_auth_token,
      :call_from => phone_call.from,
      :call_to => phone_call.to,
      :call_sid => phone_call.sid,
      :call_direction => phone_call.direction,
      :call_status => phone_call.twilio_status,
      :api_version => phone_call.api_version
    )
  end
end

