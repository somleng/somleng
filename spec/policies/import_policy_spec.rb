require "rails_helper"

RSpec.describe ImportPolicy, type: :policy do
  describe "#create?" do
    it "allows access for carrier admins" do
      user = build_stubbed(:user, :admin)

      policy = ImportPolicy.new(user)

      expect(policy.create?).to eq(true)
    end

    it "denies access for account admins" do
      account_membership = build_stubbed(:account_membership, :admin)

      policy = ImportPolicy.new(account_membership.user)

      expect(policy.create?).to eq(false)
    end
  end
end
