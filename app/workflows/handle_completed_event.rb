class HandleCompletedEvent < HandlePhoneCallEvent
  def call
    event.phone_call.complete!
  end
end
