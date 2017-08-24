require 'rails_helper'

describe PhoneCallEvent::RecordingCompleted do
  let(:factory) { :phone_call_event_recording_completed }
  let(:asserted_phone_call_event_name) { :phone_call_event_recording_completed }
  include_examples("phone_call_event")
end
