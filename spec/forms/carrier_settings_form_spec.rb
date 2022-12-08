require "rails_helper"

RSpec.describe CarrierSettingsForm do
  describe "validations" do
    it "validates the subdomain is unique" do
      create(:carrier, subdomain: "my-carrier")
      carrier = create(:carrier)

      form = CarrierSettingsForm.new(carrier:, subdomain: "my-carrier")

      expect(form).to be_invalid
      expect(form.errors[:subdomain]).to be_present
    end

    it "allows the custom app host and custom api host to be blank" do
      create(:carrier)
      carrier = create(:carrier)

      form = CarrierSettingsForm.new(carrier:)
      form.valid?

      expect(form.errors[:custom_app_host]).to be_blank
      expect(form.errors[:custom_api_host]).to be_blank
    end

    it "validates the custom app host is unique" do
      create(:carrier, custom_app_host: "my-carrier.example.com")
      carrier = create(:carrier)

      form = CarrierSettingsForm.new(carrier:, custom_app_host: "my-carrier.example.com")

      expect(form).to be_invalid
      expect(form.errors[:custom_app_host]).to be_present
    end

    it "validates the custom api host is unique" do
      create(:carrier, custom_api_host: "api.my-carrier.example.com")
      carrier = create(:carrier)

      form = CarrierSettingsForm.new(carrier:, custom_api_host: "api.my-carrier.example.com")

      expect(form).to be_invalid
      expect(form.errors[:custom_api_host]).to be_present
    end

    it "validates the custom app host and custom api host are different" do
      carrier = create(:carrier)
      form = CarrierSettingsForm.new(
        carrier:,
        custom_app_host: "my-carrier.example.com",
        custom_api_host: "my-carrier.example.com"
      )

      expect(form).to be_invalid
      expect(form.errors[:custom_api_host]).to be_present
    end

    it "validates the website" do
      form = CarrierSettingsForm.new(website: "http://www.example.com")

      form.valid?

      expect(form.errors[:website]).to be_empty
    end
  end
end
