require "rails_helper"

RSpec.describe ImportPolicy, type: :policy do
  describe "#create?" do
    it "allows access for carrier admins" do
      user_context = build_user_context_for_carrier(role: :admin)

      policy = ImportPolicy.new(user_context)

      expect(policy.create?).to eq(true)
    end

    it "denies access for account admins" do
      user_context = build_user_context_for_account(role: :admin)

      policy = ImportPolicy.new(user_context)

      expect(policy.create?).to eq(false)
    end
  end
end
