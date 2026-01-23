require "rails_helper"

RSpec.describe RefreshCarrierRates do
  it "refreshes the rates for all carriers" do
    carrier = create(:carrier)
    create_list(:account, 2, billing_enabled: true, carrier:)
    create(:account, billing_enabled: false)
    client = instance_spy(RatingEngineClient)

    RefreshCarrierRates.call(client:)

    expect(client).to have_received(:refresh_carrier_rates).once.with(carrier)
  end
end
