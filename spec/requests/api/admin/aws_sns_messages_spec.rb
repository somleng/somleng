require 'rails_helper'

describe "'/api/admin/aws_sns_messages'" do
  def account_params
    super.merge(:permissions => [:manage_aws_sns_messages])
  end

  def setup_scenario
  end

  before do
    setup_scenario
  end

  describe "POST '/'" do
    # From: http://docs.aws.amazon.com/sns/latest/dg/SendMessageToHttp.html
    # From: http://docs.aws.amazon.com/sns/latest/dg/json-formats.html

    let(:params) { "{}" }

    def headers
      {}
    end

    def post_aws_sns_messages
      do_request(
        :post,
        api_admin_aws_sns_messages_path,
        params,
        headers
     )
    end

    def setup_scenario
      super
      post_aws_sns_messages
    end

    context "unauthorized request" do
      def account_params
        super.merge(:permissions => [])
      end

      it { assert_unauthorized! }
    end

    context "valid requests" do
      let(:payload) { build(factory, factory_attributes).payload }
      let(:params) { payload.to_json }

      def factory_attributes
        {}
      end

      def headers
        {
          "x-amz-sns-message-type" => payload["Type"],
          "x-amz-sns-message-id" => payload["MessageId"],
          "x-amz-sns-topic-arn" => payload["TopicArn"]
        }
      end

      let(:created_sns_message) { AwsSnsMessage::Base.last! }

      def post_aws_sns_messages
        perform_enqueued_jobs { super }
      end

      def assert_valid_request!
        expect(response.code).to eq("201")
        expect(response.body).to be_empty
        expect(created_sns_message).to be_a(asserted_sns_message_type)
        expect(created_sns_message.aws_sns_message_id).to eq(payload["MessageId"])
      end

      context "sns_message_type => SubscriptionConfirmation" do
        let(:factory) { :aws_sns_message_subscription_confirmation }
        let(:asserted_sns_message_type) { AwsSnsMessage::SubscriptionConfirmation }
        it { assert_valid_request! }
      end

      context "sns_message_type => Notification" do
        let(:factory) { :aws_sns_message_notification }
        let(:asserted_sns_message_type) { AwsSnsMessage::Notification }

        let(:original_file_id) { SecureRandom.uuid }

        let(:recording) {
          create(
            :recording,
            :waiting_for_file,
            :original_file_id => original_file_id
          )
        }

        let(:sns_message_s3_object_id) { "recordings/#{original_file_id}-2.wav" }

        let(:content_type) { "audio/x-wav" }
        let(:recording_file) {
          Refile::FileDouble.new("dummy", "logo.wav", :content_type => content_type)
        }

        def setup_scenario
          recording
          allow(Aws::S3::Client).to receive(:new).and_return(
            Aws::S3::Client.new(
              :stub_responses => {
                :get_object => {
                  :body => recording_file,
                  :content_type => content_type
                }
              }
            )
          )
          super
        end

        def factory_attributes
          super.merge(
            :sns_message_s3_object_id => sns_message_s3_object_id
          )
        end

        def assert_valid_request!
          super
          recording.reload
          expect(recording.file.read).to eq(recording_file.read)
          expect(recording.file_content_type).to eq(content_type)
          expect(recording.file_filename).to eq(File.basename(sns_message_s3_object_id))
          expect(recording).to be_completed
        end

        it { assert_valid_request! }
      end
    end
  end
end
