require "rails_helper"

RSpec.describe CarrierSettingsPolicy, type: :policy do
  describe "#update?" do
    it "allows access to carrier owners" do
      carrier = build_stubbed(:carrier)
      user_context = build_user_context_for_carrier(role: :owner, carrier: carrier)
      policy = CarrierSettingsPolicy.new(user_context, carrier)

      expect(policy.update?).to eq(true)
    end

    it "denies access to carrier admins" do
      carrier = build_stubbed(:carrier)
      user_context = build_user_context_for_carrier(role: :admin, carrier: carrier)
      policy = CarrierSettingsPolicy.new(user_context, carrier)

      expect(policy.update?).to eq(false)
    end
  end
end
