require "rails_helper"

RSpec.describe AlphanumericSenderIDPolicy, type: :policy do
  describe "#manage?" do
    it "denies access to carrier members" do
      carrier = build_stubbed(:carrier)
      user = build_stubbed(:user, :member, carrier:)
      policy = AlphanumericSenderIDPolicy.new(user)

      expect(policy.manage?).to be(false)
    end

    it "denies access to account members" do
      account_membership = build_stubbed(:account_membership, :member)
      policy = AlphanumericSenderIDPolicy.new(account_membership.user)

      expect(policy.manage?).to be(false)
    end
  end

  describe "#destroy?" do
    it "denies access to carrier members" do
      carrier = build_stubbed(:carrier)
      user = build_stubbed(:user, :member, carrier:)
      alphanumeric_sender_id = build_stubbed(:alphanumeric_sender_id, account: build_stubbed(:account, :carrier_managed, carrier:))
      policy = AlphanumericSenderIDPolicy.new(user, alphanumeric_sender_id)

      expect(policy.destroy?).to be(false)
    end

    it "denies access to carrier users destroying customer managed resources" do
      carrier = build_stubbed(:carrier)
      alphanumeric_sender_id = build_stubbed(:alphanumeric_sender_id, account: build_stubbed(:account, :customer_managed, carrier:))
      user = build_stubbed(:user, :carrier, :admin, carrier:)
      policy = AlphanumericSenderIDPolicy.new(user, alphanumeric_sender_id)

      expect(policy.destroy?).to be(false)
    end
  end
end
