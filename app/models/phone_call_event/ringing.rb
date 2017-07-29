class PhoneCallEvent::Ringing < PhoneCallEvent::Base

  private

  def phone_call_event_name
    :phone_call_event_ringing
  end
end
