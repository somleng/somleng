require 'rails_helper'

describe AwsSnsMessage::NotificationObserver do
  let(:aws_sns_message) { create(:aws_sns_message_notification) }

  def setup_scenario
    subject.aws_sns_message_notification_created(aws_sns_message)
  end

  before do
    setup_scenario
  end

  def assert_observed!
  end

  it { assert_observed! }
end
