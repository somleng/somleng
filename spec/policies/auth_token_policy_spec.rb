require "rails_helper"

RSpec.describe AuthTokenPolicy, type: :policy do
  describe "#read?" do
    it "denies access to carrier members" do
      carrier = build_stubbed(:carrier)
      user = build_stubbed(:user, :member, carrier:)
      policy = AuthTokenPolicy.new(user)

      expect(policy.read?).to be(false)
    end

    it "denies access to account members" do
      account_membership = build_stubbed(:account_membership, :member)
      policy = AuthTokenPolicy.new(account_membership.user)

      expect(policy.read?).to be(false)
    end
  end

  describe "#destroy?" do
    it "denies access to carrier users for customer managed auth tokens" do
      carrier = build_stubbed(:carrier)
      user = build_stubbed(:user, :admin, carrier:)
      auth_token = build_stubbed(:auth_token, account: build_stubbed(:account, :customer_managed))
      policy = AuthTokenPolicy.new(user, auth_token)

      expect(policy.destroy?).to be(false)
    end

    it "denies access for revoked tokens" do
      carrier = build_stubbed(:carrier)
      user = build_stubbed(:user, :admin, carrier:)
      auth_token = build_stubbed(:auth_token, :revoked, account: build_stubbed(:account, :carrier_managed))
      policy = AuthTokenPolicy.new(user, auth_token)

      expect(policy.destroy?).to be(false)
    end
  end
end
