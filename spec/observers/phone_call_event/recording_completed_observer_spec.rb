require 'rails_helper'

describe PhoneCallEvent::RecordingCompletedObserver do
  let(:phone_call) { create(:phone_call) }

  let(:recording_duration) { "8640" }
  let(:recording_uri) { "file:///freeswitch-recordings/#{asserted_file_id}-2.wav" }
  let(:asserted_file_id) { "5daef060-ff11-42ba-a1e9-69e49a4c494f" }

  let(:event_params) {
    {
      "recording_duration"=> recording_duration,
      "recording_size"=>"0",
      "recording_uri" => recording_uri
    }
  }

  let(:phone_call_event) {
    create(
      :phone_call_event_recording_completed,
      :phone_call => phone_call,
      :params => event_params
    )
  }

  def setup_scenario
    subject.phone_call_event_recording_completed_created(phone_call_event)
  end

  before do
    setup_scenario
  end

  def assert_observed!
    expect(phone_call.reload.recording).to eq(nil)
  end

  context "phone call is not recording" do
    def assert_observed!
      super
      expect(phone_call_event.recording).to eq(nil)
    end
  end

  context "phone call is recording" do
    let(:recording) { create(:recording, :phone_call => phone_call) }

    def setup_scenario
      phone_call.recording = recording
      super
    end

    def assert_observed!
      super
      recording.reload
      expect(phone_call_event.recording).to eq(recording)
      expect(recording.params).to eq(event_params)
      expect(recording.duration).to eq(recording_duration.to_i)
      expect(recording.original_file_id).to eq(asserted_file_id)
      expect(recording.status).to eq(asserted_status)
    end

    context "recording_uri is sent" do
      let(:asserted_status) { "waiting_for_file" }

      def assert_observed!
        super
        expect(recording).to be_waiting_for_file
      end

      it { assert_observed! }
    end

    context "no recording_uri is sent" do
      let(:recording_uri) { nil }
      let(:asserted_file_id) { nil }
      let(:asserted_status) { "failed" }

      it { assert_observed! }
    end
  end
end

