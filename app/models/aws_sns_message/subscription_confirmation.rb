class AwsSnsMessage::SubscriptionConfirmation < AwsSnsMessage::Base
  def self.to_event_name
    :aws_sns_message_subscription_confirmation
  end
end
