require "rails_helper"
require Rails.root.join("db/application_seeder")

describe ApplicationSeeder do
  describe "#seed!" do
    it "creates a new account" do
      ApplicationSeeder.new.seed!

      account = Account.first
      expect(account).to be_present
      expect(account.auth_token).to be_present
      expect(account.phone_numbers).to be_present
      expect(account.phone_numbers.first.configuration).to be_present
    end

    it "does not create a new account if one already exists" do
      carrier = create(:carrier)
      existing_account = create(:account, :with_access_token, carrier:)
      create(:phone_number, carrier:, account: existing_account)
      create(:user, :carrier, carrier:)

      ApplicationSeeder.new.seed!

      account = Account.first
      expect(Account.count).to eq(1)
      expect(Carrier.count).to eq(1)
      expect(account.auth_token).to eq(existing_account.auth_token)
      expect(account.phone_numbers.count).to eq(1)
    end
  end
end
