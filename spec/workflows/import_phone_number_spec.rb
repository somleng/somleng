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
        visibility: nil,
        country: nil,
        price: nil,
        currency: nil,
        region: nil,
        locality: nil
      }
    )
    expect(phone_number).to have_attributes(
      number: have_attributes(value: "1234"),
      type: "short_code",
      visibility: "private",
      country: ISO3166::Country.new("KH")
    )
  end

  it "handles optional attributes" do
    carrier = create(:carrier, country_code: "CA", billing_currency: "CAD")
    import = create(:import, carrier:, resource_type: "PhoneNumber")

    phone_number = ImportPhoneNumber.call(
      import:,
      data: {
        number: "16473095500",
        type: "local ",
        visibility: "public ",
        country: "CA",
        price: "1.15",
        region: "ON ",
        locality: "   Kitchener   Waterloo "
      }
    )

    expect(phone_number).to have_attributes(
      number: have_attributes(value: "16473095500"),
      visibility: "public",
      country: ISO3166::Country.new("CA"),
      price: Money.from_amount(1.15, "CAD"),
      iso_region_code: "ON",
      locality: "Kitchener Waterloo"
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
      visibility: "public",
      price: Money.from_amount(1.00, "USD"),
      carrier:,
    )

    ImportPhoneNumber.call(
      import:,
      data: {
        number: "12513095542",
        type: "local",
        visibility: "private",
        country: "CA",
        price: "1.15",
        currency: "USD"
      }
    )

    expect(phone_number.reload).to have_attributes(
      number: have_attributes(value: "12513095542"),
      type: "local",
      visibility: "private",
      country: ISO3166::Country.new("CA"),
      price: Money.from_amount(1.15, "USD")
    )
  end

  it "handles invalid attributes" do
    carrier = create(:carrier)
    import = create(:import, carrier:, resource_type: "PhoneNumber")

    expect {
      ImportPhoneNumber.call(import:, data: { number: "12513095542", type: "short_code", visibility: "invalid" })
    }.to raise_error(Errors::ImportError)
  end
end
