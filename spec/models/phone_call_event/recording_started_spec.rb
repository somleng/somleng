require 'rails_helper'

describe PhoneCallEvent::RecordingStarted do
  let(:factory) { :phone_call_event_recording_started }
  let(:asserted_phone_call_event_name) { :phone_call_event_recording_started }
  include_examples("phone_call_event")
end
