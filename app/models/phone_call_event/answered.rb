class PhoneCallEvent::Answered < PhoneCallEvent::Base

  private

  def phone_call_event_name
    :phone_call_event_answered
  end
end
