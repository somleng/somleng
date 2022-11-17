require "rails_helper"

RSpec.describe PhoneNumberConfigurationPolicy, type: :policy do
  describe "#update?" do
    it "allows access for account admins" do
      account_membership = build_stubbed(:account_membership, :admin)
      policy = PhoneNumberConfigurationPolicy.new(account_membership.user)

      expect(policy.update?).to eq(true)
    end

    it "allows access to carrier admins" do
      carrier = create(:carrier)
      account = create(:account, carrier:)
      phone_number = create(:phone_number, account:, carrier:)
      user = build_stubbed(:user, :admin, carrier: account.carrier)
      policy = PhoneNumberConfigurationPolicy.new(user, phone_number)

      expect(policy.update?).to eq(true)
    end

    it "allows access to managing carriers" do
      carrier = create(:carrier)
      managing_carrier = create(:carrier)
      account = create(:account, carrier:)
      phone_number = create(:phone_number, carrier:, managing_carrier:, account:)
      user = build_stubbed(:user, :carrier, :admin, carrier: managing_carrier)
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

    it "denies access to owning carriers" do
      carrier = create(:carrier)
      managing_carrier = create(:carrier)
      account = create(:account, carrier:)
      phone_number = create(:phone_number, carrier:, managing_carrier:, account:)
      user = build_stubbed(:user, :carrier, :admin, carrier:)
      policy = PhoneNumberConfigurationPolicy.new(user, phone_number)

      expect(policy.update?).to eq(false)
    end
  end
end
