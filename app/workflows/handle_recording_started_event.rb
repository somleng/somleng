class HandleRecordingStartedEvent < HandlePhoneCallEvent
  def call
    create_recording
  end

  private

  def create_recording
    Recording.create!(
      twiml_instructions: event.params,
      phone_call: event.phone_call,
      currently_recording_phone_call: event.phone_call,
      phone_call_events: [event]
    )
  end
end
