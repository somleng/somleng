require "rails_helper"

RSpec.describe CarrierSettingsPolicy, type: :policy do
  describe "#update?" do
    it "allows access to carrier owners" do
      carrier = build_stubbed(:carrier)
      user = build_stubbed(:user, :owner, carrier:)
      policy = CarrierSettingsPolicy.new(user, carrier)

      expect(policy.update?).to eq(true)
    end

    it "denies access to carrier admins" do
      carrier = build_stubbed(:carrier)
      user = build_stubbed(:user, :admin, carrier:)
      policy = CarrierSettingsPolicy.new(user, carrier)

      expect(policy.update?).to eq(false)
    end
  end
end
