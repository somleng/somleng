require "rails_helper"

RSpec.describe ImportPhoneNumber do
  it "imports a phone number" do
    carrier = create(:carrier, country_code: "KH")
    import = create(:import, carrier:, resource_type: "PhoneNumber")

    phone_number = ImportPhoneNumber.call(import:, data: { number: "1234" })
    expect(phone_number).to have_attributes(
      number: "1234",
      enabled: true,
      country: ISO3166::Country.new("KH")
    )
  end

  it "handles optional attributes" do
    carrier = create(:carrier, country_code: "KH")
    import = create(:import, carrier:, resource_type: "PhoneNumber")

    phone_number = ImportPhoneNumber.call(
      import:,
      data: {
        number: "1234",
        enabled: false,
        country: "US"
      }
    )

    expect(phone_number).to have_attributes(
      number: "1234",
      enabled: false,
      country: ISO3166::Country.new("US")
    )
  end

  it "handles updates" do
    carrier = create(:carrier)
    import = create(:import, carrier:, resource_type: "PhoneNumber")
    phone_number = create(:phone_number, number: "12513095542", iso_country_code: "US", enabled: true, carrier:)

    ImportPhoneNumber.call(
      import:,
      data: {
        number: "12513095542",
        enabled: false,
        country: "CA"
      }
    )

    expect(phone_number.reload).to have_attributes(
      number: "12513095542",
      enabled: false,
      country: ISO3166::Country.new("CA")
    )
  end

  it "handles invalid attributes" do
    carrier = create(:carrier)
    import = create(:import, carrier:, resource_type: "PhoneNumber")

    expect {
      ImportPhoneNumber.call(import:, data: { number: "12513095542", country: "KH" })
    }.to raise_error(Errors::ImportError)
  end
end
