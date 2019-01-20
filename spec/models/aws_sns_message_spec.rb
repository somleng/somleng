require "rails_helper"

RSpec.describe AwsSnsMessage do
  it { is_expected.to enumerize(:type).in(:subscription_confirmation, :notification, :unsubscribe_confirmation) }
end
