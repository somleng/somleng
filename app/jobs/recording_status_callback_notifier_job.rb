# frozen_string_literal: true

class RecordingStatusCallbackNotifierJob < ApplicationJob
  DEFAULT_STATUS_CALLBACK_METHOD = 'POST'

  VALID_STATUS_CALLBACK_METHODS = [
    DEFAULT_STATUS_CALLBACK_METHOD, 'GET'
  ].freeze

  attr_accessor :recording

  def perform(recording_id)
    self.recording = Recording.find(recording_id)
    recording.validate_status_callback_url = true
    recording.valid?
    if recording.errors[:status_callback_url].empty?
      twilio_http_request.execute!(http_request)
    end
  end

  private

  def twilio_http_request
    @twilio_http_request ||= TwilioHttpClientRequest.new
  end

  def http_request
    @http_request ||= Somleng::TwilioHttpClient::Request.new(
      request_url: recording.status_callback_url,
      request_method: status_callback_method || DEFAULT_STATUS_CALLBACK_METHOD,
      account_sid: recording.account_sid,
      call_sid: recording.call_sid,
      auth_token: recording.account_auth_token,
      body: {
        'RecordingSid' => recording.id,
        'RecordingUrl' => recording.url,
        'RecordingStatus' => recording.twilio_status,
        'RecordingDuration' => recording.duration_seconds,
        'RecordingChannels' => recording.channels,
        'RecordingSource' => recording.source
      }
    )
  end

  def status_callback_method
    (VALID_STATUS_CALLBACK_METHODS.include?(recording.status_callback_method.to_s.upcase) && recording.status_callback_method) || DEFAULT_STATUS_CALLBACK_METHOD
  end
end
