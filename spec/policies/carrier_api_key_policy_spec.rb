require "rails_helper"

RSpec.describe CarrierAPIKeyPolicy, type: :policy do
  describe "#read?" do
    it "denies access to carrier members" do
      carrier = build_stubbed(:carrier)
      user = build_stubbed(:user, :member, carrier:)
      policy = CarrierAPIKeyPolicy.new(user)

      expect(policy.read?).to be(false)
    end

    it "denies access to account owners" do
      account_membership = build_stubbed(:account_membership, :owner)
      policy = CarrierAPIKeyPolicy.new(account_membership.user)

      expect(policy.read?).to be(false)
    end
  end

  describe "#destroy?" do
    it "denies access for revoked tokens" do
      carrier = create(:carrier, :with_oauth_application)
      user = build_stubbed(:user, :admin, carrier:)
      auth_token = build_stubbed(:carrier_api_key, :revoked, oauth_application: carrier.oauth_application)
      policy = CarrierAPIKeyPolicy.new(user, auth_token)

      expect(policy.destroy?).to be(false)
    end
  end
end
