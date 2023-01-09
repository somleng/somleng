require "rails_helper"

RSpec.describe ExpireInitiatingPhoneCalls do
  it "expires initiating phone calls" do
    to_be_expired_phone_call = create(:phone_call, :initiating, initiating_at: 2.days.ago)
    phone_call = create(:phone_call, :initiating, initiated_at: 11.hours.ago)

    ExpireInitiatingPhoneCalls.call

    expect(to_be_expired_phone_call.reload.canceled?).to eq(true)
    expect(phone_call.reload.canceled?).to eq(false)
  end
end
