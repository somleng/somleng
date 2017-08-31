class PhoneCallEvent::Ringing < PhoneCallEvent::Base
  def self.to_event_name
    :phone_call_event_ringing
  end
end
