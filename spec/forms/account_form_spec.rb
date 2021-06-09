require "rails_helper"

RSpec.describe AccountForm do
  describe "#save" do
    it "creates an account" do
      carrier = create(:carrier)
      form = AccountForm.new(name: "Rocket Rides", enabled: true)
      form.carrier = carrier

      result = form.save

      expect(result).to eq(true)
      expect(form.account).to have_attributes(
        access_token: be_present,
        name: "Rocket Rides",
        enabled?: true
      )
    end
  end
end
