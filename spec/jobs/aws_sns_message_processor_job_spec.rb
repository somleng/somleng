require 'rails_helper'

describe AwsSnsMessageProcessorJob do
  describe "#perform(headers, json_payload)" do
    let(:json_payload_factory) { :aws_sns_message_notification }

    let(:sns_message_type) { "Notification" }
    let(:sns_message_id) { SecureRandom.uuid }

    let(:payload) {
      build(
        json_payload_factory,
        :sns_message_type => sns_message_type,
        :sns_message_id => sns_message_id
      ).payload
    }

    let(:json_payload) { payload.to_json }

    def headers
      {
        "HTTP_X_AMZ_SNS_MESSAGE_TYPE" => sns_message_type,
        "HTTP_X_AMZ_SNS_MESSAGE_ID" => sns_message_id
      }
    end

    let(:created_aws_sns_message) { AwsSnsMessage::Base.last }

    def setup_scenario
      subject.perform(headers, json_payload)
    end

    before do
      setup_scenario
    end

    def assert_performed!
      expect(created_aws_sns_message).to be_present
      expect(created_aws_sns_message).to be_a(asserted_aws_sns_message_type)
      expect(created_aws_sns_message.headers).to eq(headers)
      expect(created_aws_sns_message.payload).to eq(payload)
      expect(created_aws_sns_message.aws_sns_message_id).to eq(sns_message_id)
    end

    context "SubscriptionConfirmation" do
      let(:sns_message_type) { "SubscriptionConfirmation" }
      let(:asserted_aws_sns_message_type) { AwsSnsMessage::SubscriptionConfirmation }

      it { assert_performed! }
    end

    context "Notification" do
      let(:sns_message_type) { "Notification" }
      let(:asserted_aws_sns_message_type) { AwsSnsMessage::Notification }

      it { assert_performed! }
    end
  end
end
