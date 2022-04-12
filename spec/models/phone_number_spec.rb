require "rails_helper"

RSpec.describe PhoneNumber do
  describe "#release!" do
    it "releases a phone number from an account" do
      phone_number = create(
        :phone_number,
        :assigned_to_account,
        voice_url: "https://example.com",
        voice_method: "GET",
        status_callback_url: "https://example.com",
        status_callback_method: "POST",
        sip_domain: "sip.example.com"
      )

      phone_number.release!

      expect(phone_number).to have_attributes(
        account: nil,
        voice_url: nil,
        voice_method: nil,
        status_callback_url: nil,
        status_callback_method: nil,
        sip_domain: nil
      )
    end
  end
end
