require "rails_helper"
require Rails.root.join("db/application_seeder")

describe ApplicationSeeder do
  describe "#seed!" do
    it "creates a new account" do
      seeder = described_class.new

      expect { seeder.seed! }.to output(
        /Account SID.+Auth Token/m
      ).to_stdout

      account = Account.first

      expect(account).to be_present
      expect(account.auth_token).to be_present
    end

    it "does not create a new account if one already exists" do
      seeder = described_class.new
      create(:account)

      expect { seeder.seed! }.to output.to_stdout

      expect(Account.count).to eq(1)
    end
  end
end
