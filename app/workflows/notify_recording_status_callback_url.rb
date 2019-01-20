require "somleng/twilio_http_client/request"

class NotifyRecordingStatusCallbackUrl < ApplicationWorkflow
  DEFAULT_STATUS_CALLBACK_METHOD = "POST".freeze

  attr_accessor :recording

  def initialize(recording)
    self.recording = recording
  end

  def call
    send_webhook_notification!
  end

  private

  def send_webhook_notification!
    Somleng::TwilioHttpClient::Request.new(
      request_url: recording.status_callback_url,
      request_method: recording.status_callback_method || DEFAULT_STATUS_CALLBACK_METHOD,
      account_sid: recording.account_id,
      call_sid: recording.phone_call.id,
      auth_token: recording.account.auth_token,
      body: {
        "RecordingSid" => recording.id,
        "RecordingUrl" => recording.url,
        "RecordingStatus" => recording.twilio_status,
        "RecordingDuration" => recording.duration_seconds,
        "RecordingChannels" => recording.channels,
        "RecordingSource" => recording.source
      }
    ).execute!
  end
end
