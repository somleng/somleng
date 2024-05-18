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

    it "validates the region" do
      carrier = create(:carrier)

      form = PhoneNumberForm.new(number: "12513095542", country: "CA", region: "AK", carrier:)

      expect(form).to be_invalid
      expect(form.errors[:region]).to be_present
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

  it "saves new records" do
    carrier = create(:carrier)
    form = PhoneNumberForm.new(
      number: "12366130852",
      type: "local",
      carrier:
    )

    result = form.save

    expect(result).to be_truthy

    expect(form.phone_number).to have_attributes(
      carrier:,
      type: "local"
    )
  end

  it "updates existing records" do
    carrier = create(:carrier, billing_currency: "USD")
    phone_number = create(
      :phone_number,
      number: "12366130852",
      iso_country_code: "US",
      type: "local",
      price: Money.from_amount(1.15, "USD"),
      carrier:
    )

    form = PhoneNumberForm.new(
      phone_number:,
      type: "mobile",
      country: "CA",
      price: "2.00",
      carrier:
    )

    result = form.save

    expect(result).to be_truthy

    expect(form.phone_number).to have_attributes(
      type: "mobile",
      iso_country_code: "CA",
      price: Money.from_amount(2.00, "USD")
    )
  end
end
