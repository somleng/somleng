require "rails_helper"

describe "AWS SNS Notifications" do
  # def account_params
  #   super.merge(permissions: [:manage_aws_sns_messages])
  # end
  #
  # def setup_scenario; end
  #
  # before do
  #   setup_scenario
  # end

  describe "POST /api/admin/aws_sns_messages" do
    # From: http://docs.aws.amazon.com/sns/latest/dg/SendMessageToHttp.html
    # From: http://docs.aws.amazon.com/sns/latest/dg/json-formats.html

    fit "denies unauthorized access" do
      post(api_admin_aws_sns_messages_path)

      expect(response.code).to eq("401")
    end

    it "creates an AWS SNS Subscription Confirmation" do
      params = attributes_for(
        :aws_sns_message_subscription_confirmation
      ).fetch(:payload)

      perform_enqueued_jobs do
        post(
          api_admin_aws_sns_messages_path,
          params: params.to_json,
          headers: build_sns_headers(params)
        )
      end

      expect(response.code).to eq("201")
      sns_message = AwsSnsMessage::SubscriptionConfirmation.last
      expect(sns_message).to be_present
      expect(sns_message.aws_sns_message_id).to eq(params.fetch("MessageId"))
    end


    # let(:sns_message_s3_object_id) { "recordings/#{original_file_id}-2.wav" }
    #
    # let(:recording_file) do
    #   attributes_for(
    #     :recording,
    #     :with_wav_file
    #   )[:file]
    # end

    fit "creates an AWS SNS Notification" do
      account = create(:account, :with_access_token)
      phone_call = create(:phone_call, account: account)
      recording_file = attributes_for(:recording, :with_wav_file).fetch(:file)

      recording = create(
        :recording, :waiting_for_file, :with_status_callback_url,
        phone_call: phone_call,
        original_file_id: SecureRandom.uuid
      )

      params = attributes_for(
        :aws_sns_message_notification,
        sns_message_s3_object_id: "recordings/#{recording.original_file_id}-2.wav"
      ).fetch(:payload)

      perform_enqueued_jobs do
        post(
          api_admin_aws_sns_messages_path,
          params: params.to_json,
          headers: build_sns_headers(params)
        )
      end

      expect(response.code).to eq("201")
      sns_message = AwsSnsMessage::Notification.last
      expect(sns_message).to be_present
      expect(sns_message.aws_sns_message_id).to eq(params.fetch("MessageId"))
      recording.reload
      expect(recording.file.read).to eq(recording_file.read)
      expect(recording.file_content_type).to eq(recording_file.content_type)
      expect(recording.file_filename).to eq(File.basename(sns_message_s3_object_id))
      expect(recording).to be_completed
      expect(WebMock).to have_requested(
        :post, recording.status_callback_url
      )
    end

    def build_sns_headers(params)
      build_authorization_headers.merge(
        "x-amz-sns-message-type" => params.fetch("Type"),
        "x-amz-sns-message-id" => params.fetch("MessageId"),
        "x-amz-sns-topic-arn" => params.fetch("TopicArn")
      )
    end

    def build_authorization_headers
      { "HTTP_AUTHORIZATION" => encode_credentials }
    end

    def encode_credentials
      ActionController::HttpAuthentication::Basic.encode_credentials("user", "password")
    end
  end
end

    # let(:params) { "{}" }
    #
    # def headers
    #   {}
    # end
    #
    # def post_aws_sns_messages
    #   do_request(
    #     :post,
    #     api_admin_aws_sns_messages_path,
    #     params,
    #     headers
    #   )
    # end
    #
    # def setup_scenario
    #   super
    #   post_aws_sns_messages
    # end

    # context "valid requests" do
    #   let(:payload) { build(factory, factory_attributes).payload }
    #   let(:params) { payload.to_json }
    #
    #   def factory_attributes
    #     {}
    #   end
    #
    #   def headers
    #     {
    #       "x-amz-sns-message-type" => payload["Type"],
    #       "x-amz-sns-message-id" => payload["MessageId"],
    #       "x-amz-sns-topic-arn" => payload["TopicArn"]
    #     }
    #   end
    #
    #   let(:created_sns_message) { AwsSnsMessage::Base.last! }
    #
    #   def post_aws_sns_messages
    #     perform_enqueued_jobs { super }
    #   end
    #
    #   def assert_valid_request!
    #     expect(response.code).to eq("201")
    #     expect(response.body).to be_empty
    #     expect(created_sns_message).to be_a(asserted_sns_message_type)
    #     expect(created_sns_message.aws_sns_message_id).to eq(payload["MessageId"])
    #   end

      # context "sns_message_type => SubscriptionConfirmation" do
      #   let(:factory) { :aws_sns_message_subscription_confirmation }
      #   let(:asserted_sns_message_type) { AwsSnsMessage::SubscriptionConfirmation }
      #
      #   it { assert_valid_request! }
      # end

      # context "sns_message_type => Notification" do
      #   # let(:factory) { :aws_sns_message_notification }
      #   # let(:asserted_sns_message_type) { AwsSnsMessage::Notification }
      #   #
      #   # let(:original_file_id) { SecureRandom.uuid }
      #   #
      #   # let(:phone_call) { create(:phone_call, :from_account_with_access_token) }
      #
      #   # let(:recording) do
      #   #   create(
      #   #     :recording,
      #   #     :waiting_for_file,
      #   #     :with_status_callback_url,
      #   #     phone_call: phone_call,
      #   #     original_file_id: original_file_id
      #   #   )
      #   end

        # let(:sns_message_s3_object_id) { "recordings/#{original_file_id}-2.wav" }
        #
        # let(:recording_file) do
        #   attributes_for(
        #     :recording,
        #     :with_wav_file
        #   )[:file]
        # end

        # def setup_scenario
        #   recording
        #   allow(Aws::S3::Client).to receive(:new).and_return(
        #     Aws::S3::Client.new(
        #       stub_responses: {
        #         get_object: {
        #           body: recording_file,
        #           content_type: recording_file.content_type
        #         }
        #       }
        #     )
        #   )
        #   stub_request(:post, recording.status_callback_url)
        #   super
        # end

  #       def factory_attributes
  #         super.merge(
  #           sns_message_s3_object_id: sns_message_s3_object_id
  #         )
  #       end
  #
  #       def assert_valid_request!
  #         super
  #         recording.reload
  #         expect(recording.file.read).to eq(recording_file.read)
  #         expect(recording.file_content_type).to eq(recording_file.content_type)
  #         expect(recording.file_filename).to eq(File.basename(sns_message_s3_object_id))
  #         expect(recording).to be_completed
  #         expect(WebMock).to have_requested(
  #           :post, recording.status_callback_url
  #         )
  #       end
  #
  #       it { assert_valid_request! }
  #     end
  #   end
  # end
# end
