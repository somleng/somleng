require 'rails_helper'

RSpec.describe AwsSnsMessage::Notification do
  let(:factory) { :aws_sns_message_notification }
  include_examples("aws_sns_message")
end
