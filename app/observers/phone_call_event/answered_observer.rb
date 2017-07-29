class PhoneCallEvent::AnsweredObserver < PhoneCallEvent::BaseObserver

  def phone_call_event_answered_created(phone_call_event)
    self.phone_call_event = phone_call_event
    phone_call.answer!
  end
end
