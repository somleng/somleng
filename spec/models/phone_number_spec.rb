require "rails_helper"

RSpec.describe PhoneNumber do
  describe ".available" do
    it "returns available phone numbers" do
      _disabled_phone_number = create(:phone_number, :disabled)
      _assigned_phone_number = create(:phone_number, :assigned_to_account)
      phone_number = create(:phone_number)

      result = PhoneNumber.available

      expect(result).to match_array([ phone_number ])
    end
  end

  describe ".supported_countries" do
    it "returns the supported countries" do
      create(:phone_number, number: "15064043338", iso_country_code: "CA")
      create(:phone_number, number: "15064043339", iso_country_code: "CA")
      create(:phone_number, number: "61438765431", iso_country_code: "AU")

      result = PhoneNumber.supported_countries

      expect(
        result.map { |phone_number| phone_number.country.iso_short_name }
      ).to match_array([ "Australia", "Canada" ])
    end
  end

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

    it "validates the number is unassigned before deletion" do
      phone_number = create(:phone_number)
      account = create(:account, carrier: phone_number.carrier)
      create(:phone_number_plan, phone_number:, account:)

      expect(phone_number.destroy).to eq(false)
      expect(phone_number.errors[:base]).to be_present
    end
  end
end
