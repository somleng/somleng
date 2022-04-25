require "rails_helper"

RSpec.describe ResolvePhoneNumberCountry do
  it "resolves a phone number country" do
    result = ResolvePhoneNumberCountry.call(
      "855715500234",
      fallback_country: ISO3166::Country.new("KH")
    )

    expect(result).to eq(ISO3166::Country.new("KH"))
  end

  it "fallbacks to the provided fallback country" do
    result = ResolvePhoneNumberCountry.call(
      "12505550199",
      fallback_country: ISO3166::Country.new("CA")
    )

    expect(result).to eq(ISO3166::Country.new("CA"))
  end

  it "fallbacks to the default country from the phone number" do
    result = ResolvePhoneNumberCountry.call(
      "12505550199",
      fallback_country: ISO3166::Country.new("KH")
    )

    expect(result).to eq(ISO3166::Country.new("US"))
  end
end
