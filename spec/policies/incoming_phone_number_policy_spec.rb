require "rails_helper"

RSpec.describe IncomingPhoneNumberPolicy, type: :policy do
  describe "#update?" do
    it "allows updates to carriers for carrier managed accounts" do
      user = build_stubbed(:user, :carrier, :owner)
      incoming_phone_number = build_stubbed(:incoming_phone_number, account_type: :carrier_managed)

      policy = IncomingPhoneNumberPolicy.new(user, incoming_phone_number)

      expect(policy.update?).to eq(true)
    end

    it "denies updates to carriers for customer managed accounts" do
      user = build_stubbed(:user, :carrier, :owner)
      incoming_phone_number = build_stubbed(:incoming_phone_number, account_type: :customer_managed)

      policy = IncomingPhoneNumberPolicy.new(user, incoming_phone_number)

      expect(policy.update?).to eq(false)
    end
  end
end
