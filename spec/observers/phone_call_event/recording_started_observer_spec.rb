require 'rails_helper'

describe PhoneCallEvent::RecordingStartedObserver do
  let(:event_params) { { "recordingStatusCallback" => "http://somleng.example.com/recordings" } }
  let(:phone_call_event) { create(:phone_call_event_recording_started, :params => event_params) }

  before do
    setup_scenario
  end

  describe "#phone_call_event_recording_started_received" do
    def setup_scenario
      subject.phone_call_event_recording_started_received(phone_call_event)
    end

    def assert_observed!
      recording = phone_call_event.recording
      expect(recording).to be_present
      expect(recording.twiml_instructions).to eq(event_params)
      phone_call = phone_call_event.phone_call
      expect(phone_call.recordings).to match_array([recording])
      expect(phone_call.recording).to eq(recording)
    end

    it { assert_observed! }
  end
end

