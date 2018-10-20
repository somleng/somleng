require "rails_helper"

describe "AWS SNS Notifications" do
  describe "POST /api/internal/aws_sns_messages" do
    # From: http://docs.aws.amazon.com/sns/latest/dg/SendMessageToHttp.html
    # From: http://docs.aws.amazon.com/sns/latest/dg/json-formats.html

    it "denies unauthorized access" do
      post(api_internal_aws_sns_messages_path)

      expect(response.code).to eq("401")
    end

    it "creates an AWS SNS Subscription Confirmation" do
      params = attributes_for(
        :aws_sns_message_subscription_confirmation
      ).fetch(:payload)

      perform_enqueued_jobs do
        post(
          api_internal_aws_sns_messages_path,
          params: params.to_json,
          headers: build_sns_headers(params)
        )
      end

      expect(response.code).to eq("201")
      sns_message = AwsSnsMessage::SubscriptionConfirmation.last
      expect(sns_message).to be_present
      expect(sns_message.aws_sns_message_id).to eq(params.fetch("MessageId"))
    end

    it "creates an AWS SNS Notification" do
      account = create(:account, :with_access_token)
      phone_call = create(:phone_call, account: account)
      recording_file = attributes_for(:recording, :with_wav_file).fetch(:file)

      recording = create(
        :recording, :waiting_for_file, :with_status_callback_url,
        phone_call: phone_call,
        original_file_id: SecureRandom.uuid
      )

      sns_message_s3_object_id = "recordings/#{recording.original_file_id}-2.wav"

      params = attributes_for(
        :aws_sns_message_notification,
        sns_message_s3_object_id: sns_message_s3_object_id
      ).fetch(:payload)

      stub_request(:post, recording.status_callback_url)

      allow(Aws::S3::Client).to receive(:new).and_return(
        Aws::S3::Client.new(
          stub_responses: {
            get_object: {
              body: recording_file,
              content_type: recording_file.content_type
            }
          }
        )
      )

      perform_enqueued_jobs do
        post(
          api_internal_aws_sns_messages_path,
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
  end
end
