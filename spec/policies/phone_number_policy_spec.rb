require "rails_helper"

RSpec.describe PhoneNumberPolicy, type: :policy do
  describe "#update?" do
    it "allows access if the phone number is unassigned" do
      carrier = create(:carrier)
      user_context = build_user_context_for_carrier(role: :admin, carrier:)
      phone_number = create(:phone_number, carrier:)

      policy = PhoneNumberPolicy.new(user_context, phone_number)

      expect(policy.update?).to eq(true)
    end

    it "denies access if the phone number is assigned" do
      carrier = create(:carrier)
      user_context = build_user_context_for_carrier(role: :admin, carrier:)
      account = create(:account, carrier:)
      phone_number = create(:phone_number, account:)

      policy = PhoneNumberPolicy.new(user_context, phone_number)

      expect(policy.update?).to eq(false)
    end
  end
end
