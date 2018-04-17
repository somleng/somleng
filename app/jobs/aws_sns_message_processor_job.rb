# frozen_string_literal: true

class AwsSnsMessageProcessorJob < ApplicationJob
  MESSAGE_TYPES = {
    'SubscriptionConfirmation' => AwsSnsMessage::SubscriptionConfirmation,
    'Notification' => AwsSnsMessage::Notification
  }.freeze

  def perform(headers, json_payload)
    message = message_type(
      headers['HTTP_X_AMZ_SNS_MESSAGE_TYPE']
    ).new(headers: headers)
    message.aws_sns_message_id = headers['HTTP_X_AMZ_SNS_MESSAGE_ID']
    message.payload = JSON.parse(json_payload)
    subscribe_listeners(message)
    message.received
    message.save
  end

  private

  def subscribe_listeners(message)
    message.subscribe(AwsSnsMessage::NotificationObserver.new)
  end

  def message_type(type_header)
    MESSAGE_TYPES[type_header] || AwsSnsMessage::Base
  end
end
