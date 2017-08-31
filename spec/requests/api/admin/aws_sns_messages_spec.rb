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

    let(:sns_message_id) { SecureRandom.uuid }
    let(:sns_message_type_subscription_confirmation) { "SubscriptionConfirmation" }
    let(:sns_message_type_notification) { "Notification" }
    let(:sns_topic_arn) { "arn:aws:sns:us-west-2:123456789012:MyTopic" }
    let(:sns_subscription_arn) { "#{sns_topic_arn}:abcdee55-f60b-48fd-8faf-6d41544bfab3" }
    let(:sns_message_type) { sns_message_type_subscription_confirmation }

    let(:payload) { "{}" }

    def headers
      {
        "x-amz-sns-message-type" => sns_message_type,
        "x-amz-sns-message-id" => sns_message_id,
        "x-amz-sns-topic-arn" => sns_topic_arn
      }
    end

    def post_aws_sns_messages
      do_request(
        :post,
        api_admin_aws_sns_messages_path,
        payload,
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

    context "authorized requests" do
      context "valid requests" do
        let(:created_sns_message) { AwsSnsMessage::Base.last! }

        def post_aws_sns_messages
          perform_enqueued_jobs { super }
        end

        def assert_valid_request!
          expect(response.code).to eq("201")
          expect(response.body).to be_empty
          expect(created_sns_message).to be_a(asserted_sns_message_type)
          expect(created_sns_message.aws_sns_message_id).to eq(sns_message_id)
        end

        context "sns_message_type => SubscriptionConfirmation" do
          let(:sns_message_type) { sns_message_type_subscription_confirmation }
          let(:asserted_sns_message_type) { AwsSnsMessage::SubscriptionConfirmation }

          let(:payload) {
            "{\"Type\":\"#{sns_message_type}\",\"MessageId\":\"#{sns_message_id}\",\"Token\":\"2336412f37fb687f5d51e6e241d09c805a5a57b30d712f794cc5f6a988666d92768dd60a747ba6f3beb71854e285d6ad02428b09ceece29417f1f02d609c582afbacc99c583a916b9981dd2728f4ae6fdb82efd087cc3b7849e05798d2d2785c03b0879594eeac82c01f235d0e717736\",\"TopicArn\":\"#{sns_topic_arn}\",\"Message\":\"You have chosen to subscribe to the topic arn:aws:sns:us-west-2:123456789012:MyTopic.\\nTo confirm the subscription, visit the SubscribeURL included in this message.\",\"SubscribeURL\":\"https://sns.us-west-2.amazonaws.com/?Action=ConfirmSubscription&TopicArn=arn:aws:sns:us-west-2:123456789012:MyTopic&Token=2336412f37fb687f5d51e6e241d09c805a5a57b30d712f794cc5f6a988666d92768dd60a747ba6f3beb71854e285d6ad02428b09ceece29417f1f02d609c582afbacc99c583a916b9981dd2728f4ae6fdb82efd087cc3b7849e05798d2d2785c03b0879594eeac82c01f235d0e717736\",\"Timestamp\":\"2012-04-26T20:45:04.751Z\",\"SignatureVersion\":\"1\",\"Signature\":\"EXAMPLEpH+DcEwjAPg8O9mY8dReBSwksfg2S7WKQcikcNKWLQjwu6A4VbeS0QHVCkhRS7fUQvi2egU3N858fiTDN6bkkOxYDVrY0Ad8L10Hs3zH81mtnPk5uvvolIC1CXGu43obcgFxeL3khZl8IKvO61GWB6jI9b5+gLPoBc1Q=\",\"SigningCertURL\":\"https://sns.us-west-2.amazonaws.com/SimpleNotificationService-f3ecfb7224c7233fe7bb5f59f96de52f.pem\"}"
          }

          def assert_valid_request!
            super
          end

          it { assert_valid_request! }
        end

        context "sns_message_type => Notification" do
          let(:sns_message_type) { sns_message_type_notification }
          let(:asserted_sns_message_type) { AwsSnsMessage::Notification }

          context "subject => My First Message" do
            let(:sns_message_subject) { "My First Message" }
            let(:payload) {
              "{\"Type\":\"#{sns_message_type}\",\"MessageId\":\"#{sns_message_id}\",\"TopicArn\":\"#{sns_topic_arn}\",\"Subject\":\"#{sns_message_subject}\",\"Message\":\"Hello world!\",\"Timestamp\":\"2012-05-02T00:54:06.655Z\",\"SignatureVersion\":\"1\",\"Signature\":\"EXAMPLEw6JRNwm1LFQL4ICB0bnXrdB8ClRMTQFGBqwLpGbM78tJ4etTwC5zU7O3tS6tGpey3ejedNdOJ+1fkIp9F2/LmNVKb5aFlYq+9rk9ZiPph5YlLmWsDcyC5T+Sy9/umic5S0UQc2PEtgdpVBahwNOdMW4JPwk0kAJJztnc=\",\"SigningCertURL\":\"https://sns.us-west-2.amazonaws.com/SimpleNotificationService-f3ecfb7224c7233fe7bb5f59f96de52f.pem\",\"UnsubscribeURL\":\"https://sns.us-west-2.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:us-west-2:123456789012:MyTopic:c9135db0-26c4-47ec-8998-413945fb5a96\"}"
            }

            it { assert_valid_request! }
          end

          context "subject => Amazon S3 Notification" do
            let(:sns_message_subject) { "Amazon S3 Notification" }
            let(:sns_message_s3_bucket_name) { "bucket-name" }
            let(:sns_message_s3_object_id) { "recordings/abcdefb2-f8be-4a06-b6ac-158c082b38ca-2.wav" }

            let(:payload) {
              "{\n  \"Type\" : \"#{sns_message_type}\",\n  \"MessageId\" : \"#{sns_message_id}\",\n  \"TopicArn\" : \"#{sns_topic_arn}\",\n  \"Subject\" : \"#{sns_message_subject}\",\n  \"Message\" : \"{\\\"Records\\\":[{\\\"eventVersion\\\":\\\"2.0\\\",\\\"eventSource\\\":\\\"aws:s3\\\",\\\"awsRegion\\\":\\\"ap-southeast-1\\\",\\\"eventTime\\\":\\\"2017-08-31T06:00:05.262Z\\\",\\\"eventName\\\":\\\"ObjectCreated:Put\\\",\\\"userIdentity\\\":{\\\"principalId\\\":\\\"AWS:AROAJ2HUUZYOOO65N2QGI:i-0d4d562bc5c622959\\\"},\\\"requestParameters\\\":{\\\"sourceIPAddress\\\":\\\"10.0.2.216\\\"},\\\"responseElements\\\":{\\\"x-amz-request-id\\\":\\\"3F8010558C5472DA\\\",\\\"x-amz-id-2\\\":\\\"F1z++xfzffWS7zYj/xoOGgAUS9ZWv5KHJ/fJqnX8XpgtTFr2FUFApnUHLSccsCXsaSN4qU1NTdg=\\\"},\\\"s3\\\":{\\\"s3SchemaVersion\\\":\\\"1.0\\\",\\\"configurationId\\\":\\\"NjlhODdjMGYtY2YyZS00NDhmLWE1MGEtMDEyYjQ4MjBmYTQ5\\\",\\\"bucket\\\":{\\\"name\\\":\\\"#{sns_message_s3_bucket_name}\\\",\\\"ownerIdentity\\\":{\\\"principalId\\\":\\\"A3ILPUDANGSUSO\\\"},\\\"arn\\\":\\\"arn:aws:s3:::#{sns_message_s3_bucket_name}\\\"},\\\"object\\\":{\\\"key\\\":\\\"#{sns_message_s3_object_id}\\\",\\\"size\\\":144684,\\\"eTag\\\":\\\"855a2e306bcf5dab77c31e9ad73237b8\\\",\\\"sequencer\\\":\\\"0059A7A5E52F0A64D3\\\"}}}]}\",\n  \"Timestamp\" : \"2017-08-31T06:00:05.362Z\",\n  \"SignatureVersion\" : \"1\",\n  \"Signature\" : \"M/ChP5IJ94aoM8RA0aojT0j/+8ssYNWmFknfApHRg4o3uxZS4ChoLiTbiB41rEP6vLpYTNFPuBaOZefURaemr91VCHoj05tTQOmd88GQnrUPpPI0UYJRJQg3GZhVfclxjcpHHSJNl6QErZ5Xg2BN8aZmR2ZadDZs1GB0b8nuRJVK4AUDD4Y21/1Kh+I13DSgCqf7OvaX2hSCf5FjOkScXcbk42/kA3rsK+3AiHp8zMvRaN51imKYkQ+ra54MnBdYzjNAPQasDcQrG56sVli26u4tl5nWpf1RQjPYj4v/8ampLMfhlWDqNcH/hqXBSRnZvytBymzWYOJVyuKWfQluGQ==\",\n  \"SigningCertURL\" : \"https://sns.ap-southeast-1.amazonaws.com/SimpleNotificationService-433026a4050d206028891664da859041.pem\",\n  \"UnsubscribeURL\" : \"https://sns.ap-southeast-1.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=#{sns_subscription_arn}:38406e55-f60b-48fd-8faf-6d41544bfab3\"\n}"
            }

            def assert_valid_request!
              super
            end

            it { assert_valid_request! }
          end
        end
      end
    end
  end
end
