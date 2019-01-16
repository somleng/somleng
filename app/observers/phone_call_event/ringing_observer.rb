class PhoneCallEvent::RingingObserver < ApplicationObserver

  def phone_call_event_ringing_created(phone_call_event)
    self.phone_call_event = phone_call_event
    phone_call.ring!
  end
end
