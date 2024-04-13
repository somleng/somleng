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
      from: "8562078740100"
    )
    robot_message = build(
      :message,
      direction: :inbound,
      to: "855715123444",
      from: "732873"
    )

    outbound_message.save!
    inbound_message.save!
    robot_message.save!

    expect(outbound_message.beneficiary_country_code).to eq("KH")
    expect(inbound_message.beneficiary_country_code).to eq("LA")
    expect(robot_message.beneficiary_country_code).to eq(nil)
    expect(robot_message.beneficiary_fingerprint).to eq(nil)
  end

  it "handles status timestamps" do
    message = build(:message, status: :queued)

    message.save!

    expect(message.reload.queued_at).to be_present
  end

  describe "#validity_period_expired?" do
    it "returns if the validity period is expired" do
      expired_message = create(:message, :queued, queued_at: 5.seconds.ago, validity_period: 5)
      expect(expired_message.validity_period_expired?).to eq(true)

      normal_message = create(:message, :queued, validity_period: nil)
      expect(normal_message.validity_period_expired?).to eq(false)

      valid_message = create(:message, :queued, validity_period: 5)
      expect(valid_message.validity_period_expired?).to eq(false)
    end
  end
end
