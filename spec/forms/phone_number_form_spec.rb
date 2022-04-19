require "rails_helper"

RSpec.describe PhoneNumberForm do
  describe "validations" do
    it "validates phone number is unique for the carrier" do
      carrier = create(:carrier)
      existing_phone_number = create(:phone_number, carrier:)
      form = PhoneNumberForm.new(
        carrier:,
        number: existing_phone_number.number
      )

      expect(form).to be_invalid
      expect(form.errors[:number]).to be_present
    end
  end
end
