class PhoneCallEvent::Answered < PhoneCallEvent::Base
  def self.to_event_name
    :phone_call_event_answered
  end
end
