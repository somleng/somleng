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

  describe "#save" do
    it "updates phone numbers" do
      carrier = create(:carrier)
      managing_carrier = create(:carrier)
      phone_number = create(:phone_number, carrier:, managing_carrier:)
      form = PhoneNumberForm.initialize_with(phone_number)
      form.enabled = false

      result = form.save

      expect(result).to eq(true)
      expect(phone_number.enabled).to eq(false)
      expect(phone_number.managing_carrier).to eq(managing_carrier)
    end
  end
end
