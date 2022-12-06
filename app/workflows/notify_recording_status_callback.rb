class NotifyRecordingStatusCallback < ApplicationWorkflow
  attr_reader :recording

  def initialize(recording)
    @recording = recording
  end

  def call
    TwilioAPI::NotifyWebhook.call(
      account: recording.phone_call.account,
      url: recording.status_callback_url,
      http_method: recording.status_callback_method,
      params: recording_params
    )
  end

  def recording_params
    TwilioAPI::Webhook::RecordingStatusCallbackSerializer.new(
      RecordingDecorator.new(recording)
    ).serializable_hash
  end
end
