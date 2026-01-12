require "rails_helper"

RSpec.describe RefreshCarrierRates do
  it "refreshes the rates for all carriers" do
    carrier = create(:carrier, billing_enabled: true)
    billing_disabled_carrier = create(:carrier, billing_enabled: false)
    client = instance_spy(RatingEngineClient)

    RefreshCarrierRates.call(client:)

    expect(client).to have_received(:refresh_carrier_rates).with(carrier)
    expect(client).not_to have_received(:refresh_carrier_rates).with(billing_disabled_carrier)
  end
end
