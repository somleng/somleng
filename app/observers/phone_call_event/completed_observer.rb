class PhoneCallEvent::CompletedObserver < PhoneCallEvent::BaseObserver

  def phone_call_event_completed_created(phone_call_event)
    self.phone_call_event = phone_call_event
    phone_call.completed_event = phone_call_event
    phone_call.complete!
  end
end
