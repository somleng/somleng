require "rails_helper"

RSpec.describe ImportPhoneNumber do
  it "imports a phone number" do
    carrier = create(:carrier, country_code: "KH")
    import = create(:import, carrier:, resource_type: "PhoneNumber")

    phone_number = ImportPhoneNumber.call(
      import:,
      data: {
        number: "1234",
        type: "short_code",
        enabled: nil,
        country: nil,
        price: nil,
        currency: nil
      }
    )
    expect(phone_number).to have_attributes(
      number: "1234",
      type: "short_code",
      enabled: true,
      country: ISO3166::Country.new("KH")
    )
  end

  it "handles optional attributes" do
    carrier = create(:carrier, country_code: "KH", billing_currency: "USD")
    import = create(:import, carrier:, resource_type: "PhoneNumber")

    phone_number = ImportPhoneNumber.call(
      import:,
      data: {
        number: "1234",
        type: "short_code",
        enabled: false,
        country: "US",
        price: "1.15",
        currency: "USD"
      }
    )

    expect(phone_number).to have_attributes(
      number: "1234",
      enabled: false,
      country: ISO3166::Country.new("US"),
      price: Money.from_amount(1.15, "USD")
    )
  end

  it "handles updates" do
    carrier = create(:carrier, billing_currency: "USD")
    import = create(:import, carrier:, resource_type: "PhoneNumber")
    phone_number = create(
      :phone_number,
      number: "12513095542",
      type: :mobile,
      iso_country_code: "US",
      enabled: true,
      price: Money.from_amount(1.00, "USD"),
      carrier:,
    )

    ImportPhoneNumber.call(
      import:,
      data: {
        number: "12513095542",
        type: "local",
        enabled: false,
        country: "CA",
        price: "1.15",
        currency: "USD"
      }
    )

    expect(phone_number.reload).to have_attributes(
      number: "12513095542",
      type: "local",
      enabled: false,
      country: ISO3166::Country.new("CA"),
      price: Money.from_amount(1.15, "USD")
    )
  end

  it "handles invalid attributes" do
    carrier = create(:carrier)
    import = create(:import, carrier:, resource_type: "PhoneNumber")

    expect {
      ImportPhoneNumber.call(import:, data: { number: "12513095542", type: "short_code" })
    }.to raise_error(Errors::ImportError)
  end
end
