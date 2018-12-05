class HandleRecordingStartedEvent < HandlePhoneCallEvent
  def call
    create_recording
  end

  private

  def create_recording
    event.phone_call.recordings.create!(
      twiml_instructions: event.params,
      currently_recording_phone_call: event.phone_call
    )
  end
end
