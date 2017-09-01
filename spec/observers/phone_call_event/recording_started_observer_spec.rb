require 'rails_helper'

describe PhoneCallEvent::RecordingStartedObserver do
  let(:event_params) { { "recordingStatusCallback" => "http://somleng.example.com/recordings" } }
  let(:phone_call_event) { create(:phone_call_event_recording_started, :params => event_params) }

  def setup_scenario
    subject.phone_call_event_recording_started_created(phone_call_event)
  end

  before do
    setup_scenario
  end

  def assert_observed!
    recording = phone_call_event.recording
    expect(recording).to be_present
    expect(recording.twiml_instructions).to eq(event_params)
    phone_call_event.reload
    expect(phone_call_event.phone_call.recordings).to match_array([recording])
    expect(phone_call_event.phone_call.recording).to eq(recording)
  end

  it { assert_observed! }
end

