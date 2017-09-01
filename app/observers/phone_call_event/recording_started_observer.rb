class PhoneCallEvent::RecordingStartedObserver < PhoneCallEvent::BaseObserver
  def phone_call_event_recording_started_received(phone_call_event)
    setup_observer(phone_call_event)
    phone_call_event.recording = phone_call.recordings.new(
      :twiml_instructions => phone_call_event.params,
      :currently_recording_phone_call => phone_call
    )
  end

  def phone_call_event_recording_started_created(phone_call_event)
    setup_observer(phone_call_event)
  end

  private

  def setup_observer(phone_call_event)
    self.phone_call_event = phone_call_event
  end
end
