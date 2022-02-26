class NotifyRecordingStatusCallback < ApplicationWorkflow
  attr_reader :recording

  def initialize(recording)
    @recording = recording
  end

  def call
    NotifyStatusCallback.call(
      phone_call,
      phone_call.recording_status_callback_url,
      phone_call.recording_status_callback_method,
      call_params: { placeholder: :recording_params }
    )
  end

  def phone_call
    recording.phone_call
  end
end
