require 'rails_helper'

describe PhoneCallEvent::RecordingCompletedObserver do
  let(:phone_call) { create(:phone_call) }

  let(:recording_duration) { "8640" }
  let(:recording_uri) { "file:///freeswitch-recordings/#{asserted_file_id}-2.wav" }
  let(:asserted_file_id) { "5daef060-ff11-42ba-a1e9-69e49a4c494f" }
  let(:observed_factory) { :phone_call_event_recording_completed }

  let(:recording) {
    create(
      :recording,
      :initiated,
      :phone_call => phone_call,
      :currently_recording_phone_call => phone_call
    )
  }

  def event_params
    {
      "recording_duration"=> recording_duration,
      "recording_size"=>"0",
      "recording_uri" => recording_uri
    }
  end

  def observed_factory_params
    {
      :phone_call => phone_call,
      :params => event_params
    }
  end

  before do
    setup_scenario
  end

  describe "#phone_call_event_recording_completed_received(phone_call_event)" do
    let(:phone_call_event) { build(observed_factory, observed_factory_params) }

    def setup_scenario
      subject.phone_call_event_recording_completed_received(phone_call_event)
    end

    def assert_observed!
      expect(phone_call_event.recording).to eq(asserted_recording)
    end

    context "phone call is not recording" do
      let(:asserted_recording) { nil }
      it { assert_observed! }
    end

    context "phone call is recording" do
      let(:asserted_recording) { recording }

      def setup_scenario
        recording
        super
      end

      it { assert_observed! }
    end
  end

  describe "#phone_call_event_recording_completed_created(phone_call_event)" do
    let(:phone_call_event) { create(observed_factory, observed_factory_params) }

    def setup_scenario
      subject.phone_call_event_recording_completed_created(phone_call_event)
    end

    def assert_observed!
      recording.reload
      expect(recording.status).to eq(asserted_status)
    end

    context "event.recording => recording" do
      let(:asserted_status) { "waiting_for_file" }

      def observed_factory_params
        super.merge(
          :recording => recording
        )
      end

      def assert_observed!
        super
        expect(recording.currently_recording_phone_call).to eq(nil)
        expect(recording.params).to eq(event_params)
        expect(recording.duration).to eq(recording_duration.to_i)
        expect(recording.original_file_id).to eq(asserted_file_id)
      end

      it { assert_observed! }
    end

    context "event.recording => nil" do
      let(:asserted_status) { "initiated" }
      it { assert_observed! }
    end
  end
end

