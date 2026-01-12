require "rails_helper"

RSpec.describe RefreshCarrierRates do
  it "refreshes the rates for all carriers" do
    carrier = create(:carrier)
    client = instance_spy(RatingEngineClient)

    RefreshCarrierRates.call(client:)

    expect(client).to have_received(:refresh_carrier_rates).with(carrier)
  end
end
