require "rails_helper"

RSpec.describe TwoFactorAuthenticationPolicy, type: :policy do
  describe "#new?" do
    it "allows access" do
      user_context = build_stubbed(:user_context)

      policy = TwoFactorAuthenticationPolicy.new(user_context, nil)

      expect(policy.new?).to eq(true)
    end
  end

  describe "#destroy?" do
  end
end
