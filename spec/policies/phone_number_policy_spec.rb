require "rails_helper"

RSpec.describe PhoneNumberPolicy, type: :policy do
  context "with a managing carrier" do
    it "handles access control" do
      carrier = create(:carrier)
      managing_carrier = create(:carrier)
      account = create(:account, carrier: managing_carrier)
      phone_number = create(:phone_number, carrier:, managing_carrier:, account:)
      owner_carrier_user = build_stubbed(:user, :admin, carrier:)
      managing_carrier_user = build_stubbed(:user, :admin, carrier: managing_carrier)

      owner_carrier_policy = PhoneNumberPolicy.new(owner_carrier_user, phone_number)
      managing_carrier_policy = PhoneNumberPolicy.new(managing_carrier_user, phone_number)

      expect(owner_carrier_policy.read?).to eq(true)
      expect(owner_carrier_policy.update?).to eq(false)
      expect(owner_carrier_policy.release?).to eq(false)
      expect(owner_carrier_policy.destroy?).to eq(true)

      expect(managing_carrier_policy.read?).to eq(true)
      expect(managing_carrier_policy.update?).to eq(true)
      expect(managing_carrier_policy.release?).to eq(true)
      expect(managing_carrier_policy.destroy?).to eq(false)
    end
  end

  describe "#update?" do
    it "allows access to carrier admins" do
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

  describe "#release?" do
    it "allows access if the phone number is assigned" do
      carrier = create(:carrier)
      user = build_stubbed(:user, :admin, carrier:)
      phone_number = create(:phone_number, :assigned_to_account, carrier:)

      policy = PhoneNumberPolicy.new(user, phone_number)

      expect(policy.release?).to eq(true)
    end

    it "denies access if the phone number is unassigned" do
      carrier = create(:carrier)
      user = build_stubbed(:user, :admin, carrier:)
      phone_number = create(:phone_number, carrier:)

      policy = PhoneNumberPolicy.new(user, phone_number)

      expect(policy.release?).to eq(false)
    end
  end
end
