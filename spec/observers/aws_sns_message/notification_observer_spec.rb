require 'rails_helper'

describe AwsSnsMessage::NotificationObserver do
  let(:observing_factory) { :aws_sns_message_notification }
  let(:s3_bucket_name) { "my-bucket" }
  let(:original_file_id) { SecureRandom.uuid }
  let(:s3_object_id) { "recordings/#{original_file_id}-2.wav" }

  def recording_factory_traits
    {
      :waiting_for_file => nil
    }
  end

  def recording_factory_attributes
    {
      :original_file_id => original_file_id
    }
  end

  let(:recording) {
    create(
      :recording,
      *recording_factory_traits.keys,
      recording_factory_attributes
    )
  }

  def factory_attributes
    {
      :sns_message_s3_object_id => s3_object_id,
      :sns_message_s3_bucket_name => s3_bucket_name
    }
  end

  before do
    setup_scenario
  end

  describe "#aws_sns_message_notification_received(aws_sns_message)" do
    let(:aws_sns_message) {
      build(observing_factory, factory_attributes)
    }

    def setup_scenario
      subject.aws_sns_message_notification_received(aws_sns_message)
    end

    context "no recording exists with the original_file_id" do
      def assert_observed!
        expect(aws_sns_message.recording).to eq(nil)
      end

      it { assert_observed! }
    end

    context "a recording exists with the original_file_id" do
      let(:sns_message_event_source) { "aws:s3" }

      def factory_attributes
        super.merge(
          :sns_message_event_source => sns_message_event_source,
          :sns_message_event_name => sns_message_event_name
        )
      end

      def setup_scenario
        recording
        super
      end

      def assert_observed!
        expect(aws_sns_message.recording).to eq(asserted_recording)
      end

      context "aws:s3 ObjectCreated:Put event" do
        let(:sns_message_event_name) { "ObjectCreated:Put" }
        let(:asserted_recording) { recording }

        context "s3_object_id is not a uuid" do
          let(:original_file_id) { nil }
          let(:s3_object_id) { "abc" }
          let(:asserted_recording) { nil }

          it { assert_observed! }
        end

        context "current recording is not waiting_for_file" do
          let(:asserted_recording) { nil }

          def recording_factory_traits
            {
              :initiated => true
            }
          end

          it { assert_observed! }
        end

        it { assert_observed! }
      end

      context "aws:s3 ObjectDeleted event" do
        let(:sns_message_event_name) { "ObjectDeleted:Delete" }
        let(:asserted_recording) { nil }
        it { assert_observed! }
      end
    end
  end

  describe "#aws_sns_message_notification_created(aws_sns_message)" do
    let(:aws_sns_message) {
      create(observing_factory, factory_attributes)
    }

    let(:enqueued_job) { enqueued_jobs.first }

    def setup_scenario
      subject.aws_sns_message_notification_created(aws_sns_message)
    end

    context "a recording does not exist for this notification" do
      def assert_observed!
        expect(enqueued_job).to eq(nil)
      end

      it { assert_observed! }
    end

    context "a recording exists for ths notification" do
      def factory_attributes
        super.merge(:recording => recording)
      end

      def assert_observed!
        expect(enqueued_job[:job]).to eq(RecordingProcessorJob)
        expect(enqueued_job[:args]).to match_array([recording.id, s3_bucket_name, s3_object_id])
      end

      it { assert_observed! }
    end
  end
end
