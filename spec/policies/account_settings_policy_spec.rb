require "rails_helper"

RSpec.describe AccountSettingsPolicy, type: :policy do
  describe "#update?" do
    it "allows access to account owners" do
      account_membership = build_stubbed(:account_membership, :owner)
      policy = AccountSettingsPolicy.new(account_membership.user, account_membership.account)

      expect(policy.update?).to eq(true)
    end

    it "denies access to account admins" do
      account_membership = build_stubbed(:account_membership, :admin)
      policy = AccountSettingsPolicy.new(account_membership.user, account_membership.account)

      expect(policy.update?).to eq(false)
    end
  end
end
