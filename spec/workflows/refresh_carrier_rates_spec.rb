require "rails_helper"

RSpec.describe RefreshCarrierRates do
  it "refreshes the rates for all carriers" do
    carrier = create(:carrier, :billing_enabled)
    create(:account, :billing_enabled, carrier:)
    create(:account, :billing_enabled, carrier:)
    create(:account, :billing_enabled, carrier: create(:carrier, billing_enabled: false))
    create(:account, billing_enabled: false, carrier: create(:carrier, :billing_enabled))
    client = instance_spy(RatingEngineClient)

    RefreshCarrierRates.call(client:)

    expect(client).to have_received(:refresh_carrier_rates).once
    expect(client).to have_received(:refresh_carrier_rates).with(carrier)
  end
end
