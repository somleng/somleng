require "rails_helper"

RSpec.describe CarrierStanding do
  describe "#good_standing?" do
    it "returns whether the carrier is in good standing" do
      stub_const("CarrierStanding::MAX_TRIAL_INTERACTIONS_PER_MONTH", 1)
      carrier = create(:carrier)
      restricted_carrier = create(:carrier, :restricted)
      restricted_carrier_with_max_interactions = create(:carrier, :restricted)
      create(:interaction, carrier: restricted_carrier_with_max_interactions)

      expect(CarrierStanding.new(carrier).good_standing?).to eq(true)
      expect(CarrierStanding.new(restricted_carrier).good_standing?).to eq(true)
      expect(CarrierStanding.new(restricted_carrier_with_max_interactions).good_standing?).to eq(false)
    end
  end

  describe "#remaining_interactions" do
    it "returns the remaining interactions" do
      stub_const("CarrierStanding::MAX_TRIAL_INTERACTIONS_PER_MONTH", 100)
      carrier = create(:carrier, :restricted)
      create_list(:interaction, 2, carrier:)

      expect(CarrierStanding.new(carrier).remaining_interactions).to eq(98)
    end

    it "handles interaction credits" do
      stub_const("CarrierStanding::MAX_TRIAL_INTERACTIONS_PER_MONTH", 100)
      carrier = create(:carrier, :restricted)
      create(:trial_interactions_credit_voucher, carrier:, number_of_interactions: 500)
      create(:trial_interactions_credit_voucher, carrier:, number_of_interactions: 100)
      create_list(:interaction, 2, carrier:)

      expect(CarrierStanding.new(carrier).remaining_interactions).to eq(598)
    end
  end
end
