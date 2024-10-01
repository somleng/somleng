require "rails_helper"

RSpec.describe ImportPhoneNumber do
  it "imports a phone number" do
    carrier = create(:carrier, country_code: "KH")
    import = create_import(carrier:)

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
    import = create_import(carrier:)

    phone_number = ImportPhoneNumber.call(
      import:,
      data: {
        number: "16473095500",
        type: "local ",
        visibility: "public ",
        country: "CA",
        price: "1.15",
        region: "ON ",
        locality: "   Kitchener   Waterloo ",
        meta_my_custom_field: "   My custom  field  value   ",
        meta_another_custom_field: "   Another   custom   field  value   "
      }
    )

    expect(phone_number).to have_attributes(
      number: have_attributes(value: "16473095500"),
      visibility: "public",
      country: ISO3166::Country.new("CA"),
      price: Money.from_amount(1.15, "CAD"),
      iso_region_code: "ON",
      locality: "Kitchener Waterloo",
      metadata: {
        "my_custom_field" => "My custom field value",
        "another_custom_field" => "Another custom field value"
      }
    )
  end

  it "handles updates" do
    carrier = create(:carrier, billing_currency: "USD")
    import = create_import(carrier:)
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
        number: "+(1) 251-309-5542",
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
    import = create_import

    expect {
      ImportPhoneNumber.call(import:, data: { number: "12513095542", type: "short_code", visibility: "invalid" })
    }.to raise_error(Errors::ImportError)
  end

  it "fails to create a phone number with marked_for_deletion flag" do
    import = create_import

    expect {
      ImportPhoneNumber.call(
        import:,
        data: {
          number: "12513095542",
          type: "local",
          marked_for_deletion: nil
        }
      )
    }.to raise_error(Errors::ImportError)
  end

  it "deletes a number" do
    import = create_import
    phone_number = create(
      :phone_number,
      number: "12513095542",
      carrier: import.carrier,
    )

    ImportPhoneNumber.call(
      import:,
      data: {
        number: "12513095542",
        marked_for_deletion: "true"
      }
    )

    expect(PhoneNumber.find_by(id: phone_number.id)).to eq(nil)
  end

  it "fails to delete a number if other attributes are given" do
    import = create_import
    create(
      :phone_number,
      number: "12513095542",
      carrier: import.carrier
    )

    expect {
      ImportPhoneNumber.call(
        import:,
        data: {
          number: "12513095542",
          marked_for_deletion: "true",
          type: "local"
        }
      )
    }.to raise_error(Errors::ImportError)
  end

  it "fails to delete a number not explicitly marked for deletion" do
    import = create_import
    create(
      :phone_number,
      number: "12513095542",
      carrier: import.carrier
    )

    expect {
      ImportPhoneNumber.call(
        import:,
        data: {
          number: "12513095542",
          marked_for_deletion: "X"
        }
      )
    }.to raise_error(Errors::ImportError)
  end

  it "fails to delete a phone number that does not exist" do
    import = create_import
    expect {
      ImportPhoneNumber.call(
        import:,
        data: {
          number: "12513095542",
          marked_for_deletion: "true"
        }
      )
    }.to raise_error(Errors::ImportError)
  end

  it "fails to delete a phone number with an active plan" do
    import = create_import
    account = create(:account, carrier: import.carrier)
    create(
      :phone_number,
      :assigned,
      account:,
      number: "12513095542",
      carrier: import.carrier
    )

    expect {
      ImportPhoneNumber.call(
        import:,
        data: {
          number: "12513095542",
          marked_for_deletion: "true"
        }
      )
    }.to raise_error(Errors::ImportError)
  end

  def create_import(carrier: nil)
    carrier ||= create(:carrier)
    user = create(:user, carrier:)
    create(:import, user:, resource_type: "PhoneNumber")
  end
end
