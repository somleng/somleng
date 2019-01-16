class HandleRecordingCompletedEvent < HandlePhoneCallEvent
  def call
    complete_recording
  end
end
