require "rails_helper"

RSpec.resource "Available Phone Numbers", document: :twilio_api do
  # https://www.twilio.com/docs/phone-numbers/api/availablephonenumber-resource#read-a-list-of-countries

  get "https://api.somleng.org/2010-04-01/Accounts/:account_sid/AvailablePhoneNumbers" do
    example "Read a list of countries" do
      account = create(:account)
      create(:phone_number, iso_country_code: "KH", carrier: account.carrier)
      create(:phone_number, iso_country_code: "CA", carrier: account.carrier)
      create(:phone_number, iso_country_code: "CA", carrier: account.carrier)

      set_twilio_api_authorization_header(account)
      do_request(account_sid: account.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_collection_schema("twilio_api/country", pagination: false)
      expect(json_response.fetch("countries").count).to eq(2)
      expect(json_response.dig("countries", 0)).to include(
        "country_code" => "CA",
        "country" => "Canada",
        "uri" => api_twilio_account_available_phone_number_country_path(account, "CA", format: :json)
      )
      expect(json_response.dig("countries", 1)).to include(
        "country_code" => "KH",
        "country" => "Cambodia",
        "uri" => api_twilio_account_available_phone_number_country_path(account, "KH", format: :json)
      )
    end
  end

  # https://www.twilio.com/docs/phone-numbers/api/availablephonenumber-resource#fetch-a-specific-country

  get "https://api.somleng.org/2010-04-01/Accounts/:account_sid/AvailablePhoneNumbers/:country_code" do
    example "Fetch a specific country" do
      account = create(:account)
      create(:phone_number, iso_country_code: "CA", carrier: account.carrier)

      set_twilio_api_authorization_header(account)
      do_request(account_sid: account.id, country_code: "CA")

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/country")
      expect(json_response).to include(
        "country_code" => "CA",
        "country" => "Canada"
      )
    end
  end
end
