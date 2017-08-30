class PhoneCallEvent::RecordingStarted < PhoneCallEvent::Base
  private

  def phone_call_event_name
    :phone_call_event_recording_started
  end
end
