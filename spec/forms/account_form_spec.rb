require "rails_helper"

RSpec.describe AccountForm do
  describe "#save" do
    it "creates an account with an access token" do
      carrier = create(:carrier)
      account_form = AccountForm.new(name: "Rocket Rides", enabled: true)
      account_form.carrier = carrier

      result = account_form.save

      expect(result).to eq(true)
      expect(account_form.account.access_token).to be_present
    end
  end
end
