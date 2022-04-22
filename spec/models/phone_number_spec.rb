require "rails_helper"

RSpec.describe PhoneNumber do
  describe "validations" do
    it "validates the uniqueness of the number scoped to the carrier" do
      existing_phone_number = create(:phone_number)
      duplicate_phone_number = build(
        :phone_number,
        carrier: existing_phone_number.carrier,
        number: existing_phone_number.number
      )
      other_phone_number = build(
        :phone_number,
        carrier: existing_phone_number.carrier
      )
      other_carrier_phone_number = build(
        :phone_number,
        number: existing_phone_number.number
      )

      expect(duplicate_phone_number.valid?).to eq(false)
      expect(duplicate_phone_number.errors[:number]).to be_present
      expect(other_phone_number.valid?).to eq(true)
      expect(other_carrier_phone_number.valid?).to eq(true)
    end
  end

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
