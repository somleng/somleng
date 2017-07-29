class PhoneCallEvent::BaseObserver < ApplicationObserver
  attr_accessor :phone_call_event

  private

  def phone_call
    @phone_call ||= phone_call_event.phone_call
  end
end
