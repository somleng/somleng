require "rails_helper"

RSpec.describe PhoneCall do
  it "handles beneficiary data" do
    outbound_call = build(
      :phone_call,
      direction: :outbound,
      to: "16472437399",
      from: "16472437327",
    )

    inbound_call = build(
      :phone_call,
      direction: :inbound,
      to: "16472437327",
      from: "16472437399",
      sip_trunk: create(:sip_trunk, inbound_country_code: "CA")
    )

    outbound_call.save!
    inbound_call.save!

    expect(outbound_call).to have_attributes(
      beneficiary_fingerprint: have_attributes(
        digest: Digest::SHA256.hexdigest("16472437399")
      ),
      beneficiary_country_code: "US"
    )

    expect(inbound_call).to have_attributes(
      beneficiary_fingerprint: have_attributes(
        digest: Digest::SHA256.hexdigest("16472437399")
      ),
      beneficiary_country_code: "CA"
    )
  end

  it "transitions from queued to initiating" do
    phone_call = create(:phone_call, :queued)

    phone_call.mark_as_initiating!

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

    phone_call.mark_as_initiating!

    expect(phone_call.initiating?).to eq(true)
  end
end
