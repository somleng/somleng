require 'rails_helper'

describe RecordingProcessorJob do
  describe "#perform(recording_id, bucket_name, object_key)" do
    let(:bucket_name) { "bucket-name" }
    let(:asserted_file_filename) { "object-key.wav" }
    let(:object_key) { "/recordings/#{asserted_file_filename}" }

    let(:recording_file) {
      attributes_for(
        :recording,
        :with_wav_file
      )[:file]
    }

    def stub_aws_client_responses
      allow(Aws::S3::Client).to receive(:new).and_return(
        Aws::S3::Client.new(
          :stub_responses => {
            :get_object => {
              :body => recording_file,
              :content_type => recording_file.content_type
            }
          }
        )
      )
    end

    let(:recording_factory_status) { :waiting_for_file }

    def recording_traits
      {
        recording_factory_status => nil
      }
    end

    let(:recording) { create(:recording, *recording_traits.keys) }

    let(:do_perform_before) { true }

    def setup_scenario
      stub_aws_client_responses
      do_perform! if do_perform_before
    end

    def do_perform!
      subject.perform(recording.id, bucket_name, object_key)
    end

    before do
      setup_scenario
    end

    context "processing is successful" do
      def assert_performed!
        recording.reload
        expect(recording.file.read).to eq(recording_file.read)
        expect(recording.file_content_type).to eq(recording_file.content_type)
        expect(recording.file_filename).to eq(asserted_file_filename)
        expect(recording).to be_completed
      end

      context "recording is waiting_for_file" do
        let(:recording_factory_status) { :waiting_for_file }
        it { assert_performed! }
      end

      context "recording is processing" do
        let(:recording_factory_status) { :processing }
        it { assert_performed! }
      end
    end

    context "error is raised during processing" do
      let(:do_perform_before) { false }

      def stub_aws_client_responses
        allow(Aws::S3::Client).to receive(:new).and_raise(RuntimeError)
      end

      def assert_performed!
        expect { do_perform! }.to raise_error(RuntimeError)
        expect(recording.reload).to be_processing
      end

      it { assert_performed! }
    end
  end
end
