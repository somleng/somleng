require 'rails_helper'

RSpec.describe AwsSnsMessage::SubscriptionConfirmation do
  let(:factory) { :aws_sns_message_subscription_confirmation }
  include_examples("aws_sns_message")
end
