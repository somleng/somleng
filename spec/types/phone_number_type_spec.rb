require "rails_helper"

RSpec.describe PhoneNumberType do
  it "handles phone number types" do
    klass = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :number, PhoneNumberType.new
    end

    expect(klass.new(number: PhoneNumberType::PhoneNumber.new).number).to be_a(PhoneNumberType::PhoneNumber)
    expect(klass.new(number: nil).number).to eq(nil)
    expect(klass.new(number: "invalid").number).to eq(nil)
    expect(klass.new(number: "1294").number).to have_attributes(
      value: "1294",
      e164?: false
    )
    expect(klass.new(number: "  sip:example.com:5080 ").number).to have_attributes(
      value: "sip:example.com:5080",
      sip?: true,
      sip_address: "example.com:5080"
    )

    cambodian_number = klass.new(number: "+855 97 222 2222").number
    expect(cambodian_number).to have_attributes(
      value: "855972222222",
      e164?: true,
      country_code: "855",
      area_code: nil,
      country: have_attributes(
        alpha2: "KH",
        iso_short_name: "Cambodia"
      )
    )
    expect(cambodian_number.possible_countries).to contain_exactly(ISO3166::Country.new("KH"))

    north_american_number = klass.new(number: "+1 (236) 613-9238").number
    expect(north_american_number).to have_attributes(
      value: "12366139238",
      e164?: true,
      country_code: "1",
      area_code: "236",
      country: nil
    )
    expect(north_american_number.possible_countries.map(&:country_code).uniq).to contain_exactly("1")
  end
end
