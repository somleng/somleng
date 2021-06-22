require "rails_helper"

RSpec.describe AccountSettingsPolicy, type: :policy do
  describe "#update?" do
    it "allows access to account owners" do
      account = build_stubbed(:account)
      user_context = build_user_context_for_account(role: :owner, account: account)
      policy = AccountSettingsPolicy.new(user_context, account)

      expect(policy.update?).to eq(true)
    end

    it "denies access to account admins" do
      account = build_stubbed(:account)
      user_context = build_user_context_for_account(role: :admin, account: account)
      policy = AccountSettingsPolicy.new(user_context, account)

      expect(policy.update?).to eq(false)
    end
  end
end
