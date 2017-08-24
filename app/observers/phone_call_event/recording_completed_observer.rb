class PhoneCallEvent::RecordingCompletedObserver < PhoneCallEvent::BaseObserver
  def phone_call_event_recording_completed_created(phone_call_event)
    JobAdapter.new(:recording_processor_worker).perform_later(phone_call_event.id)
  end
end
