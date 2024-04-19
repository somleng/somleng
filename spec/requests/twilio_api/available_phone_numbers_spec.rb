require "rails_helper"

RSpec.resource "Available Phone Numbers", document: :twilio_api do
  # https://www.twilio.com/docs/phone-numbers/api/availablephonenumber-resource#read-a-list-of-countries
  get "https://api.somleng.org/2010-04-01/Accounts/:account_sid/AvailablePhoneNumbers" do
    explanation <<~HEREDOC
      You can query the `AvailablePhoneNumbers` to get a list of `subresources` available for your account by ISO Country.
    HEREDOC

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

  # https://www.twilio.com/docs/phone-numbers/api/availablephonenumberlocal-resource#read-multiple-availablephonenumberlocal-resources
  get "https://api.somleng.org/2010-04-01/Accounts/:account_sid/AvailablePhoneNumbers/:country_code" do
    explanation <<~HEREDOC
      Fetch the `subresources` available for a specific country.
    HEREDOC

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

  get "https://api.somleng.org/2010-04-01/Accounts/:account_sid/AvailablePhoneNumbers/:country_code/:type" do
    # https://www.twilio.com/docs/phone-numbers/api/availablephonenumberlocal-resource
    example "List the available local phone numbers for a specific country" do
      account = create(:account)
      create(:phone_number, number: "15067020972", type: :local, iso_country_code: "CA", carrier: account.carrier)
      create(:phone_number, number: generate(:canadian_toll_free_number), type: :toll_free, iso_country_code: "CA", carrier: account.carrier)
      create(:phone_number, number: generate(:us_local_number), type: :local, iso_country_code: "US", carrier: account.carrier)

      set_twilio_api_authorization_header(account)
      do_request(account_sid: account.id, country_code: "CA", type: "Local")

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_collection_schema("twilio_api/available_phone_number")
      expect(json_response.fetch("available_phone_numbers").count).to eq(1)
      expect(json_response.dig("available_phone_numbers", 0)).to include(
        "phone_number" => "+15067020972",
        "friendly_name" => "(506) 702-0972",
        "iso_country" => "CA"
      )
    end

    # https://www.twilio.com/docs/phone-numbers/api/availablephonenumber-mobile-resource#read-multiple-availablephonenumbermobile-resources
    example "List the available mobile phone numbers for a specific country" do
      account = create(:account)
      create(:phone_number, number: "15067020972", type: :mobile, iso_country_code: "CA", carrier: account.carrier)
      create(:phone_number, number: generate(:canadian_toll_free_number), type: :toll_free, iso_country_code: "CA", carrier: account.carrier)

      set_twilio_api_authorization_header(account)
      do_request(account_sid: account.id, country_code: "CA", type: "Mobile")

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_collection_schema("twilio_api/available_phone_number")
      expect(json_response.fetch("available_phone_numbers").count).to eq(1)
      expect(json_response.dig("available_phone_numbers", 0, "phone_number")).to eq("+15067020972")
    end

    # https://www.twilio.com/docs/phone-numbers/api/availablephonenumber-tollfree-resource#read-multiple-availablephonenumbertollfree-resources
    example "List the available toll free phone numbers for a specific country" do
      account = create(:account)
      create(:phone_number, number: "18777318091", type: :toll_free, iso_country_code: "CA", carrier: account.carrier)
      create(:phone_number, number: generate(:canadian_local_number), type: :local, iso_country_code: "CA", carrier: account.carrier)

      set_twilio_api_authorization_header(account)
      do_request(account_sid: account.id, country_code: "CA", type: "TollFree")

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_collection_schema("twilio_api/available_phone_number")
      expect(json_response.fetch("available_phone_numbers").count).to eq(1)
      expect(json_response.dig("available_phone_numbers", 0, "phone_number")).to eq("+18777318091")
    end

    example "Handles invalid requests", document: false do
      account = create(:account)

      set_twilio_api_authorization_header(account)
      do_request(account_sid: account.id, country_code: "CA", type: "Invalid")

      expect(response_status).to eq(400)
      expect(response_body).to match_api_response_schema("twilio_api/api_errors")
    end
  end
end
