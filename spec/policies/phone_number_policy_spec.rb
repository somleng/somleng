require "rails_helper"

RSpec.describe PhoneNumberPolicy, type: :policy do
  describe "#update?" do
    it "allows access for carrier admin" do
      carrier = create(:carrier)
      user = build_stubbed(:user, :admin, carrier:)
      phone_number = build_stubbed(:phone_number, carrier:)

      policy = PhoneNumberPolicy.new(user, phone_number)

      expect(policy.update?).to eq(true)
    end

    it "denies access for account admins" do
      account_membership = build_stubbed(:account_membership, :admin)

      policy = PhoneNumberPolicy.new(account_membership.user)

      expect(policy.update?).to eq(false)
    end
  end
end
