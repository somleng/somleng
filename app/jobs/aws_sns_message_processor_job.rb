class AwsSnsMessageProcessorJob < ActiveJob::Base
  MESSAGE_TYPES = {
    "SubscriptionConfirmation" => {
      "type" => AwsSnsMessage::SubscriptionConfirmation,
      "listeners" => []
    },
    "Notification" => {
      "type" => AwsSnsMessage::Notification,
      "listeners" => []
    }
  }

  def perform(headers, json_payload)
    message = message_type(headers["HTTP_X_AMZ_SNS_MESSAGE_TYPE"]).new(:headers => headers)
    message.aws_sns_message_id = headers["HTTP_X_AMZ_SNS_MESSAGE_ID"]
    message.payload = JSON.parse(json_payload)
    message.save
  end

  private

  def message_type(type_header)
    message_type_settings(type_header)["type"] || AwsSnsMessage::Base
  end

  def message_type_settings(type)
    MESSAGE_TYPES[type] || {}
  end
end
