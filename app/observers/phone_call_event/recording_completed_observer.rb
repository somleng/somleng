class PhoneCallEvent::RecordingCompletedObserver < PhoneCallEvent::BaseObserver
  UUID_REGEX = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/

  def phone_call_event_recording_completed_created(phone_call_event)
    self.phone_call_event = phone_call_event
    recording = phone_call_event.recording = phone_call.recording
    phone_call.recording = nil
    update_recording(recording) if recording
  end

  def update_recording(recording)
    event_params = phone_call_event.params
    recording.params = event_params
    recording.duration = event_params["recording_duration"]
    recording.original_file_id = UUIDFilename.uuid_from_uri(event_params["recording_uri"])
    recording.wait_for_file
    recording.save
  end
end
