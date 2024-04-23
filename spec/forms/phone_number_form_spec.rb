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

    it "validates the country" do
      carrier = create(:carrier)

      form = PhoneNumberForm.new(number: "12513095542", country: "KH", carrier:)

      expect(form).to be_invalid
      expect(form.errors[:country]).to be_present
    end

    it "validates the price" do
      carrier = create(:carrier)

      form = PhoneNumberForm.new(
        number: "12366130852",
        price: "-0.1",
        carrier:
      )

      expect(form).to be_invalid
      expect(form.errors[:price]).to be_present
    end
  end
end
