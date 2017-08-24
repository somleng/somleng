class PhoneCallEvent::RecordingCompleted < PhoneCallEvent::Base
  store_accessor :params,
                 :recording_duration,
                 :recording_size,
                 :recording_uri

  private

  def phone_call_event_name
    :phone_call_event_recording_completed
  end
end
