require "rails_helper"

RSpec.describe PhoneNumberConfigurationPolicy, type: :policy do
  describe "#update?" do
    it "allows access for account admins" do
      user_context = build_user_context_for_account(role: :admin)
      phone_number = create(:phone_number)
      policy = PhoneNumberConfigurationPolicy.new(user_context, phone_number)

      expect(policy.update?).to eq(true)
    end

    it "allows access to carrier admins if the phone number is carrier managed" do
      user_context = build_user_context_for_carrier(role: :admin)
      account = create(:account)
      phone_number = create(:phone_number, account: account)

      policy = PhoneNumberConfigurationPolicy.new(user_context, phone_number)

      expect(policy.update?).to eq(true)
    end

    it "denies access to carrier admins if the phone number is customer managed" do
      user_context = build_user_context_for_carrier(role: :admin)
      account = create(:account)
      create(:account_membership, account: account)
      phone_number = create(:phone_number, account: account)

      policy = PhoneNumberConfigurationPolicy.new(user_context, phone_number)

      expect(policy.update?).to eq(false)
    end

    it "denies access to carrier admins if there is no associated account" do
      carrier = create(:carrier)
      user_context = build_user_context_for_carrier(role: :admin, carrier: carrier)
      phone_number = create(:phone_number, carrier: user_context.carrier)

      policy = PhoneNumberConfigurationPolicy.new(user_context, phone_number)

      expect(policy.update?).to be_falsey
    end
  end
end
