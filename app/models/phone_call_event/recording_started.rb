class PhoneCallEvent::RecordingStarted < PhoneCallEvent::Base
  def self.to_event_name
    :phone_call_event_recording_started
  end
end
