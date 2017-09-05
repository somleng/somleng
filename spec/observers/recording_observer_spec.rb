require 'rails_helper'

describe RecordingObserver do
  def recording_factory_traits
    {}
  end

  def recording_factory_attributes
    {}
  end

  let(:recording) {
    create(:recording, *recording_factory_traits.keys, recording_factory_attributes)
  }

  describe "#recording_completed(recording)" do
    let(:enqueued_job) { enqueued_jobs.first }

    def setup_scenario
      subject.recording_completed(recording)
    end

    before do
      setup_scenario
    end

    context "recording#status_callback_url? => true" do
      def recording_factory_traits
        super.merge(:with_status_callback_url => true)
      end

      def assert_observed!
        expect(enqueued_job[:job]).to eq(RecordingStatusCallbackNotifierJob)
        expect(enqueued_job[:args]).to match_array([recording.id])
      end

      it { assert_observed! }
    end

    context "phone_call#status_callback_url? => false" do
      def assert_observed!
        expect(enqueued_job).to eq(nil)
      end

      it { assert_observed! }
    end
  end
end
