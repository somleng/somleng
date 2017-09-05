require "somleng/twilio_http_client/request"

class RecordingStatusCallbackNotifierJob < ActiveJob::Base
  DEFAULT_STATUS_CALLBACK_METHOD = "POST"

  VALID_STATUS_CALLBACK_METHODS = [
    DEFAULT_STATUS_CALLBACK_METHOD, "GET"
  ]

  attr_accessor :recording

  def perform(recording_id)
    self.recording = Recording.find(recording_id)
    recording.validate_status_callback_url = true
    recording.valid?
    if recording.errors[:status_callback_url].empty?
      http_request.execute!
    end
  end

  private

  def http_request
    @http_request ||= Somleng::TwilioHttpClient::Request.new(
      :request_url => recording.status_callback_url,
      :request_method => status_callback_method || DEFAULT_STATUS_CALLBACK_METHOD,
      :account_sid => recording.account_sid,
      :call_sid => recording.call_sid,
      :auth_token => recording.account_auth_token,
      :body => {
        "RecordingSid" => recording.id,
        "RecordingUrl" => recording.url,
        "RecordingStatus" => recording.twilio_status,
        "RecordingDuration" => recording.duration_seconds,
        "RecordingChannels" => recording.channels,
        "RecordingSource" => recording.source
      }
    )
  end

  def status_callback_method
    (VALID_STATUS_CALLBACK_METHODS.include?(recording.status_callback_method.to_s.upcase) && recording.status_callback_method) || DEFAULT_STATUS_CALLBACK_METHOD
  end
end
