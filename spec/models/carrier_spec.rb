require "rails_helper"

RSpec.describe Interaction do
  describe "#good_standing?" do
    it "returns whether the carrier is in good standing" do
      stub_const("Carrier::MAX_RESTRICTED_INTERACTIONS_PER_MONTH", 1)
      enabled_carrier = create(:carrier, :enabled)
      disabled_carrier = create(:carrier, :disabled)
      restricted_carrier = create(:carrier, :restricted)
      restricted_carrier_with_max_interactions = create(:carrier, :restricted)
      create(:interaction, carrier: restricted_carrier_with_max_interactions)

      expect(enabled_carrier.good_standing?).to eq(true)
      expect(disabled_carrier.good_standing?).to eq(false)
      expect(restricted_carrier.good_standing?).to eq(true)
      expect(restricted_carrier_with_max_interactions.good_standing?).to eq(false)
    end
  end

  describe "#remaining_interactions" do
    it "returns the remaining interactions" do
      stub_const("Carrier::MAX_RESTRICTED_INTERACTIONS_PER_MONTH", 3)
      carrier = create(:carrier, :restricted)
      create_list(:interaction, 2, carrier:)

      expect(carrier.remaining_interactions).to eq(1)
    end
  end
end
