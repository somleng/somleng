class AwsSnsMessage::Notification < AwsSnsMessage::Base
  def self.to_event_name
    :aws_sns_message_notification
  end
end
