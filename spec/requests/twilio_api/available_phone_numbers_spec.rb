require "rails_helper"

RSpec.resource "Available Phone Numbers", document: :twilio_api do
  get "https://api.somleng.org/2010-04-01/Accounts/:AccountSid/AvailablePhoneNumbers/:CountryCode/:Type" do
    parameter(
      "AccountSid",
      "*Path Parameter*: The SID of the Account requesting the AvailablePhoneNumber resources."
    )
    parameter(
      "CountryCode",
      "*Path Parameter*: The [ISO-3166-1](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) country code of the country from which to read phone numbers."
    )
    parameter(
      "Type",
      "*Path Parameter*: Type of phone numbers to read. One of #{PhoneNumber.type.values.map { |type| "`#{type.to_s.camelize}`" }.join(", ")}."
    )
    parameter(
      "AreaCode",
      "*Query Parameter*: The area code of the phone numbers to read. Applies to only phone numbers in the US and Canada."
    )

    # https://www.twilio.com/docs/phone-numbers/api/availablephonenumberlocal-resource
    example "1. List the available Local phone numbers for a specific country" do
      explanation <<~HEREDOC
        This API lets you search for `Local` phone numbers that are available for you to purchase.
      HEREDOC

      account = create(:account)

      common_attributes = {
        type: :local,
        iso_country_code: "CA",
        carrier: account.carrier,
        visibility: :public
      }

      create(:phone_number, common_attributes.merge(number: "12513095500"))
      create(:phone_number, common_attributes.merge(number: "18777318091", type: :toll_free))
      create(:phone_number, common_attributes.merge(number: "12513095502", iso_country_code: "US"))
      create(:phone_number, common_attributes.merge(number: "12513095503", visibility: :private))

      set_twilio_api_authorization_header(account)
      do_request(AccountSid: account.id, CountryCode: "CA", Type: "Local")

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_collection_schema("twilio_api/available_phone_number")
      expect(json_response.fetch("available_phone_numbers").count).to eq(1)
      expect(json_response.dig("available_phone_numbers", 0)).to include(
        "phone_number" => "+12513095500",
        "friendly_name" => "+1 (251) 309-5500",
        "iso_country" => "CA"
      )
    end

    # https://www.twilio.com/docs/phone-numbers/api/availablephonenumberlocal-resource#find-available-local-phone-numbers-by-area-code
    example "2. Find available local phone numbers by area code" do
      explanation <<~HEREDOC
        Find available `Local` phone numbers in Canada in the `201` area code.
      HEREDOC

      account = create(:account)

      common_attributes = {
        type: :local,
        iso_country_code: "CA",
        carrier: account.carrier,
        visibility: :public
      }

      create(:phone_number, common_attributes.merge(number: "12013095500"))
      create(:phone_number, common_attributes.merge(number: "12023095500"))

      set_twilio_api_authorization_header(account)
      do_request(AccountSid: account.id, CountryCode: "CA", Type: "Local", AreaCode: "201")

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_collection_schema("twilio_api/available_phone_number")
      expect(json_response.fetch("available_phone_numbers").count).to eq(1)
      expect(json_response.dig("available_phone_numbers", 0)).to include(
        "phone_number" => "+12013095500",
        "friendly_name" => "+1 (201) 309-5500",
        "iso_country" => "CA"
      )
    end

    # https://www.twilio.com/docs/phone-numbers/api/availablephonenumber-mobile-resource#read-multiple-availablephonenumbermobile-resources
    example "3. List the available Mobile phone numbers for a specific country" do
      explanation <<~HEREDOC
        This API lets you search for `Mobile` phone numbers that are available for you to purchase.
      HEREDOC

      account = create(:account)
      common_attributes = {
        type: :mobile,
        iso_country_code: "CA",
        carrier: account.carrier,
        visibility: :public
      }

      create(:phone_number, common_attributes.merge(number: "12513095500"))
      create(:phone_number, common_attributes.merge(number: "12513095501", type: :local))
      create(:phone_number, common_attributes.merge(number: "12513095502", visibility: :private))

      set_twilio_api_authorization_header(account)
      do_request(AccountSid: account.id, CountryCode: "CA", Type: "Mobile")

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_collection_schema("twilio_api/available_phone_number")
      expect(json_response.fetch("available_phone_numbers").count).to eq(1)
      expect(json_response.dig("available_phone_numbers", 0, "phone_number")).to eq("+12513095500")
    end

    # https://www.twilio.com/docs/phone-numbers/api/availablephonenumber-tollfree-resource#read-multiple-availablephonenumbertollfree-resources
    example "4. List the available Toll Free phone numbers for a specific country" do
      explanation <<~HEREDOC
        This API lets you search for `TollFree` phone numbers that are available for you to purchase.
      HEREDOC

      account = create(:account)
      common_attributes = {
        type: :toll_free,
        iso_country_code: "CA",
        carrier: account.carrier,
        visibility: :public
      }
      create(:phone_number, common_attributes.merge(number: "18777318091"))
      create(:phone_number, common_attributes.merge(number: "12513095500", type: :local))
      create(:phone_number, common_attributes.merge(number: "18777318092", visibility: :private))

      set_twilio_api_authorization_header(account)
      do_request(AccountSid: account.id, CountryCode: "CA", Type: "TollFree")

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_collection_schema("twilio_api/available_phone_number")
      expect(json_response.fetch("available_phone_numbers").count).to eq(1)
      expect(json_response.dig("available_phone_numbers", 0, "phone_number")).to eq("+18777318091")
    end

    example "5. List the available Short Code numbers for a specific country" do
      explanation <<~HEREDOC
        This API lets you search for `Short Code` phone numbers that are available for you to purchase.
      HEREDOC

      account = create(:account)
      common_attributes = {
        type: :short_code,
        iso_country_code: "CA",
        carrier: account.carrier,
        visibility: :public
      }
      create(:phone_number, common_attributes.merge(number: "1294"))
      create(:phone_number, common_attributes.merge(number: "12513095500", type: :local))

      set_twilio_api_authorization_header(account)
      do_request(AccountSid: account.id, CountryCode: "CA", Type: "ShortCode")

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_collection_schema("twilio_api/available_phone_number")
      expect(json_response.fetch("available_phone_numbers").count).to eq(1)
      expect(json_response.dig("available_phone_numbers", 0, "phone_number")).to eq("1294")
    end

    example "Handles invalid requests", document: false do
      account = create(:account)

      set_twilio_api_authorization_header(account)
      do_request(AccountSid: account.id, CountryCode: "CA", Type: "Invalid")

      expect(response_status).to eq(400)
      expect(response_body).to match_api_response_schema("twilio_api/api_errors")
    end
  end

  get "https://api.somleng.org/2010-04-01/Accounts/:AccountSid/AvailablePhoneNumbers" do
    parameter(
      "AccountSid",
      "*Path Parameter*: The SID of the Account requesting the available phone number Country resources.",
    )

    # https://www.twilio.com/docs/phone-numbers/api/availablephonenumber-resource#read-a-list-of-countries
    example "6. Read a list of countries" do
      explanation <<~HEREDOC
        You can query the `AvailablePhoneNumbers` to get a list of `subresources` available for your account by ISO Country.
        This API gets the subresources available for all supported countries.
      HEREDOC

      account = create(:account)
      create(:phone_number, number: "85512345678", carrier: account.carrier)
      create(:phone_number, number: "15678901234", iso_country_code: "CA", carrier: account.carrier)
      create(:phone_number, number: "15678901235", iso_country_code: "CA", carrier: account.carrier)

      set_twilio_api_authorization_header(account)
      do_request(AccountSid: account.id)

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

  get "https://api.somleng.org/2010-04-01/Accounts/:AccountSid/AvailablePhoneNumbers/:CountryCode" do
    parameter(
      "AccountSid",
      "*Path Parameter*: The SID of the Account requesting the available phone number Country resource.",
    )

    parameter(
      "CountryCode",
      "*Path Parameter*: The ISO-3166-1 country code of the country to fetch available phone number information about.",
    )

    # https://www.twilio.com/docs/phone-numbers/api/availablephonenumberlocal-resource#read-multiple-availablephonenumberlocal-resources
    example "7. Fetch a specific country" do
      explanation <<~HEREDOC
        Fetch the `subresources` available for a specific country. The `subresources` will contain a list of endpoints which can be used to fetch
        available phone numbers for that country.
      HEREDOC

      account = create(:account)
      create(:phone_number, number: "15067020972", iso_country_code: "CA", carrier: account.carrier)

      set_twilio_api_authorization_header(account)
      do_request(AccountSid: account.id, CountryCode: "CA")

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/country")
      expect(json_response).to include(
        "country_code" => "CA",
        "country" => "Canada"
      )
    end
  end
end
