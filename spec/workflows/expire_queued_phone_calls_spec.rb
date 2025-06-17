require "rails_helper"

RSpec.describe ExpireQueuedPhoneCalls do
  it "expires queued phone calls older than 7 days" do
    to_be_expired_queued_phone_call = create(:phone_call, :queued, created_at: 7.days.ago)
    _to_be_expired_initiating_phone_call = create(:phone_call, :initiating, created_at: 7.days.ago)
    phone_call = create(:phone_call, :queued, created_at: 6.days.ago)

    ExpireQueuedPhoneCalls.call

    expect(to_be_expired_queued_phone_call.reload.canceled?).to eq(true)
    expect(phone_call.reload.queued?).to eq(true)
  end
end
