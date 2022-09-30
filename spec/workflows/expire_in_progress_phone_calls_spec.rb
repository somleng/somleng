require "rails_helper"

RSpec.describe ExpireInProgressPhoneCalls do
  it "expires in progress phone calls" do
    to_be_expired_phone_call = create(:phone_call, :initiated, initiated_at: 4.hours.ago)
    phone_call = create(:phone_call, :initiated, initiated_at: 3.hours.ago)

    ExpireInProgressPhoneCalls.call

    expect(to_be_expired_phone_call.reload.session_timeout?).to eq(true)
    expect(phone_call.reload.session_timeout?).to eq(false)
  end
end
