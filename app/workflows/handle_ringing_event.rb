class HandleRingingEvent < HandlePhoneCallEvent
  def call
    event.phone_call.ring!
  end
end
