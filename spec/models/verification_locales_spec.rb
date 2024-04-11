require "rails_helper"

RSpec.describe VerificationLocales do
  describe ".find_by_country" do
    it "finds a locale by country" do
      expect(
        VerificationLocales.find_by_country(ISO3166::Country.new("KH")).locale
      ).to eq("km")

      expect(
        VerificationLocales.find_by_country(ISO3166::Country.new("AU")).locale
      ).to eq("en")
    end
  end
end
