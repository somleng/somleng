class PhoneCallEvent::RecordingCompletedObserver < PhoneCallEvent::BaseObserver
  def phone_call_event_recording_completed_received(phone_call_event)
    self.phone_call_event = phone_call_event
    phone_call_event.recording = phone_call.recording
  end

  def phone_call_event_recording_completed_created(phone_call_event)
    self.phone_call_event = phone_call_event
    if recording = phone_call_event.recording
      event_params = phone_call_event.params
      recording.params = event_params
      recording.duration = event_params["recording_duration"]
      recording.original_file_id = UUIDFilename.uuid_from_uri(event_params["recording_uri"])
      recording.currently_recording_phone_call = nil
      recording.wait_for_file
      recording.save
    end
  end
end
