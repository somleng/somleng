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
end
