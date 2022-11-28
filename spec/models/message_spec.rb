require "rails_helper"

RSpec.describe Message do
  it "handles beneficiary data" do
    outbound_message = build(
      :message,
      direction: :outbound_api,
      to: "855715123444",
      from: "856715123444"
    )
    inbound_message = build(
      :message,
      direction: :inbound,
      to: "855715123444",
      from: "856715123444"
    )

    outbound_message.save!
    inbound_message.save!

    expect(outbound_message.beneficiary_country_code).to eq("KH")
    expect(inbound_message.beneficiary_country_code).to eq("LA")
  end

  describe "#validity_period_expired?" do
    it "returns if the validity period is expired" do
      expired_message = create(:message, validity_period: 5, created_at: 5.seconds.ago)
      expect(expired_message.validity_period_expired?).to eq(true)

      normal_message = create(:message, validity_period: nil)
      expect(normal_message.validity_period_expired?).to eq(false)

      valid_message = create(:message, validity_period: 5)
      expect(valid_message.validity_period_expired?).to eq(false)
    end
  end
end
