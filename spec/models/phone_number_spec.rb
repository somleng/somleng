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

  describe ".utilized" do
    it "returns utilized phone numbers" do
      utilized_phone_number_with_phone_call = create_utilized_phone_number(utilized_by: :phone_call)
      utilized_phone_number_with_message = create_utilized_phone_number(utilized_by: :message)
      _unutilized_phone_number = create(:phone_number)
      utilized_phone_number_by_another_account = create_utilized_phone_number
      utilized_phone_number_by_another_account.update!(
        account: create(:account, carrier: utilized_phone_number_by_another_account.carrier)
      )

      result = PhoneNumber.utilized

      expect(result).to match_array(
        [
          utilized_phone_number_with_phone_call,
          utilized_phone_number_with_message
        ]
      )
    end
  end

  describe ".unutilized" do
    it "returns unutilized phone numbers" do
      create_utilized_phone_number(utilized_by: :phone_call)
      create_utilized_phone_number(utilized_by: :message)
      unutilized_phone_number = create(:phone_number, :assigned_to_account)
      create_list(:phone_call, 2, phone_number: unutilized_phone_number)

      result = PhoneNumber.unutilized

      expect(result).to match_array([ unutilized_phone_number ])
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
  end

  describe "#release!" do
    it "releases a phone number from an account" do
      phone_number = create(
        :phone_number,
        :assigned_to_account,
        :configured
      )
      plan = phone_number.active_plan

      phone_number.release!

      expect(phone_number.reload).to have_attributes(
        account: nil,
        configuration: nil
      )
      expect(plan.reload).to have_attributes(
        status: "canceled",
        canceled_at: be_present
      )
    end
  end

  def create_utilized_phone_number(**params)
    carrier = params.fetch(:carrier) { create(:carrier) }
    account = params.fetch(:account) { create(:account, carrier:) }
    phone_number = create(:phone_number, :assigned_to_account, carrier:, account:)
    create_list(params.fetch(:utilized_by, :phone_call), 2, phone_number:, account:)

    phone_number
  end
end
