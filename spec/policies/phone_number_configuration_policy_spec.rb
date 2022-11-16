require "rails_helper"

RSpec.describe PhoneNumberConfigurationPolicy, type: :policy do
  describe "#update?" do
    it "allows access for account admins" do
      account_membership = build_stubbed(:account_membership, :admin)
      policy = PhoneNumberConfigurationPolicy.new(account_membership.user)

      expect(policy.update?).to eq(true)
    end

    it "allows access to carrier admins if the phone number is carrier managed" do
      user = build_stubbed(:user, :admin)
      account = create(:account)
      phone_number = create(:phone_number, account:)

      policy = PhoneNumberConfigurationPolicy.new(user, phone_number)

      expect(policy.update?).to eq(true)
    end

    it "allows access to managing carriers if the phone number is carrier managed" do
      carrier = create(:carrier)
      managing_carrier = create(:carrier)
      user = create(:user, :carrier, :admin, carrier: managing_carrier)

      phone_number = create(:phone_number, carrier:, managed_by_carrier: managing_carrier)

      policy = PhoneNumberConfigurationPolicy.new(user, phone_number)

      expect(policy.update?).to eq(true)
    end

    it "denies access to carrier admins if the phone number is customer managed" do
      user = build_stubbed(:user, :admin)
      account = create(:account)
      create(:account_membership, account:)
      phone_number = create(:phone_number, account:)

      policy = PhoneNumberConfigurationPolicy.new(user, phone_number)

      expect(policy.update?).to eq(false)
    end

    it "denies access to carrier admins if there is no associated account" do
      carrier = create(:carrier)
      user = build_stubbed(:user, :admin, carrier:)
      phone_number = create(:phone_number, carrier: user.carrier)

      policy = PhoneNumberConfigurationPolicy.new(user, phone_number)

      expect(policy.update?).to be_falsey
    end

    it "denies access to owning carriers if assigned a managing carrier" do
      pending
    end
  end
end
