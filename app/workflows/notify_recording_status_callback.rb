class NotifyRecordingStatusCallback < ApplicationWorkflow
  attr_reader :recording

  def initialize(recording)
    @recording = recording
  end

  def call
    NotifyStatusCallback.call(
      phone_call: recording.phone_call,
      callback_url: recording.status_callback_url,
      callback_http_method: recording.status_callback_method,
      params: recording_params
    )
  end

  def recording_params
    TwilioAPI::RecordingStatusCallbackSerializer.new(
      RecordingDecorator.new(recording)
    ).serializable_hash
  end
end
