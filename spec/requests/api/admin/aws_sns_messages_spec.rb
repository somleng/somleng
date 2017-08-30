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
    let(:sns_message_type) { sns_message_type_subscription_confirmation }

    let(:payload) { "{}" }

    def headers
      {
        "x-amz-sns-message-type" => sns_message_type,
        "x-amz-sns-message-id" => sns_message_id
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

          let(:payload) {
            "{\"Type\":\"#{sns_message_type}\",\"MessageId\":\"#{sns_message_id}\",\"TopicArn\":\"#{sns_topic_arn}\",\"Subject\":\"My First Message\",\"Message\":\"Hello world!\",\"Timestamp\":\"2012-05-02T00:54:06.655Z\",\"SignatureVersion\":\"1\",\"Signature\":\"EXAMPLEw6JRNwm1LFQL4ICB0bnXrdB8ClRMTQFGBqwLpGbM78tJ4etTwC5zU7O3tS6tGpey3ejedNdOJ+1fkIp9F2/LmNVKb5aFlYq+9rk9ZiPph5YlLmWsDcyC5T+Sy9/umic5S0UQc2PEtgdpVBahwNOdMW4JPwk0kAJJztnc=\",\"SigningCertURL\":\"https://sns.us-west-2.amazonaws.com/SimpleNotificationService-f3ecfb7224c7233fe7bb5f59f96de52f.pem\",\"UnsubscribeURL\":\"https://sns.us-west-2.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:us-west-2:123456789012:MyTopic:c9135db0-26c4-47ec-8998-413945fb5a96\"}"
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
