require "rails_helper"

RSpec.describe PhoneCall do
  it "transitions from queued to initiating" do
    phone_call = create(:phone_call, :queued)

    phone_call.initiate!

    expect(phone_call.initiating?).to eq(true)
  end

  it "transitions from initiating to initiated" do
    phone_call = create(:phone_call, :initiating)
    phone_call.external_id = SecureRandom.uuid

    phone_call.mark_as_initiated!

    expect(phone_call.initiated?).to eq(true)
  end

  it "handles initiating multiple times" do
    phone_call = create(:phone_call, :initiating)

    phone_call.initiate!

    expect(phone_call.initiating?).to eq(true)
  end
end
