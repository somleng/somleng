require "rails_helper"

RSpec.describe PhoneNumber do
  describe "#release!" do
    it "releases a phone number from an account" do
      phone_number = create(
        :phone_number,
        :assigned_to_account,
        :configured
      )

      phone_number.release!

      expect(phone_number.reload).to have_attributes(
        account: nil,
        configuration: nil
      )
    end
  end
end
