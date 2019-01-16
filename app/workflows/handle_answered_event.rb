class HandleAnsweredEvent < HandlePhoneCallEvent
  def call
    event.phone_call.answer!
  end
end
