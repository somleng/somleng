require "rails_helper"

RSpec.resource "Incoming Phone Numbers", document: :twilio_api do
  # https://www.twilio.com/docs/phone-numbers/api/incomingphonenumber-resource

  explanation <<~HEREDOC
    An `IncomingPhoneNumber` resource represents a phone number provisioned to your account.
    The IncomingPhoneNumbers list resource represents an account's phone numbers. You can `POST` to the list resource to provision a new number. To find a new number to provision use the subresources of the [Available Phone Numbers] resource.
  HEREDOC

  post "https://api.somleng.org/2010-04-01/Accounts/:AccountSid/IncomingPhoneNumbers" do
    parameter(
      "AccountSid",
      "*Path Parameter*: The SID of the Account that will create the resource.",
    )
    parameter(
      "PhoneNumber",
      "*Request Body Parameter*: The phone number to purchase specified in E.164 format.",
      required: true
    )
    parameter(
      "FriendlyName",
      "*Request Body Parameter*: A descriptive string that you created to describe the new phone number. It can be up to 64 characters long. By default, this is a formatted version of the new phone number.",
      required: false
    )
    parameter(
      "SmsUrl",
      "*Request Body Parameter*: The URL we should call when the new phone number receives an incoming SMS message.",
      required: false
    )
    parameter(
      "SmsMethod",
      "*Request Body Parameter*: The HTTP method that we should use to call `sms_url`. Can be: `GET` or `POST` and defaults to `POST`.",
      required: false
    )
    parameter(
      "VoiceUrl",
      "*Request Body Parameter*: The URL that we should call to answer a call to the new phone number.",
      required: false
    )
    parameter(
      "VoiceMethod",
      "*Request Body Parameter*: The HTTP method that we should use to call `voice_url`. Can be: `GET` or `POST` and defaults to `POST`.",
      required: false
    )
    parameter(
      "StatusCallback",
      "*Request Body Parameter*: The URL we should call using the `status_callback_method` to send status information to your application.",
      required: false
    )
    parameter(
      "StatusCallbackMethod",
      "*Request Body Parameter*: The HTTP method we should use to call `status_callback`. Can be: `GET` or `POST` and defaults to `POST`.",
      required: false
    )

    # https://www.twilio.com/docs/phone-numbers/api/incomingphonenumber-resource#create-an-incomingphonenumber-resource
    example "1. Provision a Phone Number" do
      explanation <<~HEREDOC
        You can `POST` to this API to provision a new phone number. To find a new number to provision use the [Available Phone Numbers API](#available-phone-numbers).

        You will be charged when you provision the number, and the number will appear on the Active Numbers page in the console.
      HEREDOC

      account = create(:account)
      create(:phone_number, number: "12513095500", visibility: :public, carrier: account.carrier)

      set_twilio_api_authorization_header(account)
      do_request(
        AccountSid: account.id,
        PhoneNumber: "+12513095500",
      )

      expect(response_status).to eq(201)
      expect(response_body).to match_api_response_schema("twilio_api/incoming_phone_number")
      expect(json_response).to include(
        "phone_number" => "+12513095500"
      )
    end

    example "2. Provision a Phone Number with a Voice URL" do
      explanation <<~HEREDOC
        You will receive a HTTP request to this URL when a call comes in to your phone number.
      HEREDOC

      account = create(:account)
      create(:phone_number, number: "12513095500", visibility: :public, carrier: account.carrier)

      set_twilio_api_authorization_header(account)
      do_request(
        AccountSid: account.id,
        PhoneNumber: "+12513095500",
        VoiceUrl: "https://www.your-voice-url.com/example"
      )

      expect(response_status).to eq(201)
      expect(response_body).to match_api_response_schema("twilio_api/incoming_phone_number")
      expect(json_response).to include(
        "voice_url" => "https://www.your-voice-url.com/example",
        "voice_method" => "POST"
      )
    end

    example "3. Provision a Phone Number with an SMS URL" do
      explanation <<~HEREDOC
        You will receive a HTTP request to this URL when an SMS is sent to your phone number.
      HEREDOC

      account = create(:account)
      create(:phone_number, number: "12513095500", visibility: :public, carrier: account.carrier)

      set_twilio_api_authorization_header(account)
      do_request(
        AccountSid: account.id,
        PhoneNumber: "+12513095500",
        SmsUrl: "https://www.your-sms-url.com/example"
      )

      expect(response_status).to eq(201)
      expect(response_body).to match_api_response_schema("twilio_api/incoming_phone_number")
      expect(json_response).to include(
        "sms_url" => "https://www.your-sms-url.com/example",
        "sms_method" => "POST"
      )
    end

    example "Handles invalid requests", document: false do
      account = create(:account)

      set_twilio_api_authorization_header(account)
      do_request(
        AccountSid: account.id,
        PhoneNumber: "+12513095500",
      )

      expect(response_status).to eq(422)
      expect(response_body).to match_api_response_schema("twilio_api/api_errors")
    end
  end

  get "https://api.somleng.org/2010-04-01/Accounts/:AccountSid/IncomingPhoneNumbers/:Sid" do
    parameter(
      "AccountSid",
      "*Path Parameter*: The SID of the Account that created the IncomingPhoneNumber resource to fetch.",
    )
    parameter(
      "Sid",
      "*Path Parameter*: The SID of the IncomingPhoneNumber resource to be fetched.",
    )

    # https://www.twilio.com/docs/phone-numbers/api/incomingphonenumber-resource#fetch-an-incomingphonenumber-resource
    example "4. Fetch an IncomingPhoneNumber resource" do
      explanation <<~HEREDOC
        Fetch an IncomingPhoneNumber
      HEREDOC

      incoming_phone_number = create(:incoming_phone_number, number: "12513095500")

      set_twilio_api_authorization_header(incoming_phone_number.account)
      do_request(AccountSid: incoming_phone_number.account.id, Sid: incoming_phone_number.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/incoming_phone_number")
    end
  end

  get "https://api.somleng.org/2010-04-01/Accounts/:AccountSid/IncomingPhoneNumbers" do
    parameter(
      "AccountSid",
      "*Path Parameter*: The SID of the Account that created the IncomingPhoneNumber resource to read.",
    )
    parameter(
      "PhoneNumber",
      "*Query Parameter*: The phone number of the IncomingPhoneNumber resources to read.",
      required: false
    )

    # https://www.twilio.com/docs/phone-numbers/api/incomingphonenumber-resource#read-multiple-incomingphonenumber-resources
    example "5. Read a list of Incoming Phone Numbers" do
      explanation <<~HEREDOC
        List all IncomingPhoneNumber resources for your account.
      HEREDOC

      incoming_phone_number = create(:incoming_phone_number, number: "12513095500")
      create(:incoming_phone_number, number: "12513095501", account: incoming_phone_number.account)

      set_twilio_api_authorization_header(incoming_phone_number.account)
      do_request(AccountSid: incoming_phone_number.account_id, PhoneNumber: "+12513095500")

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_collection_schema("twilio_api/incoming_phone_number")
      expect(json_response.fetch("incoming_phone_numbers").count).to eq(1)
      expect(json_response.dig("incoming_phone_numbers", 0)).to include(
        "phone_number" => "+12513095500",
        "account_sid" => incoming_phone_number.account_id,
        "sid" => incoming_phone_number.id
      )
    end

    example "Handles invalid requests", document: false do
      account = create(:account)

      set_twilio_api_authorization_header(account)
      do_request(AccountSid: account.id, PhoneNumber: "invalid")

      expect(response_status).to eq(400)
      expect(response_body).to match_api_response_schema("twilio_api/api_errors")
    end
  end

  post "https://api.somleng.org/2010-04-01/Accounts/:AccountSid/IncomingPhoneNumbers/:Sid" do
    parameter(
      "AccountSid",
      "*Path Parameter*: The SID of the Account that created the IncomingPhoneNumber resource to update.",
    )
    parameter(
      "Sid",
      "*Path Parameter*: The SID of the IncomingPhoneNumber resource to update.",
    )
    parameter(
      "FriendlyName",
      "*Request Body Parameter*: A descriptive string that you created to describe the new phone number. It can be up to 64 characters long. By default, this is a formatted version of the new phone number.",
      required: false
    )
    parameter(
      "SmsUrl",
      "*Request Body Parameter*: The URL we should call when the new phone number receives an incoming SMS message.",
      required: false
    )
    parameter(
      "SmsMethod",
      "*Request Body Parameter*: The HTTP method that we should use to call `sms_url`. Can be: `GET` or `POST` and defaults to `POST`.",
      required: false
    )
    parameter(
      "VoiceUrl",
      "*Request Body Parameter*: The URL that we should call to answer a call to the new phone number.",
      required: false
    )
    parameter(
      "VoiceMethod",
      "*Request Body Parameter*: The HTTP method that we should use to call `voice_url`. Can be: `GET` or `POST` and defaults to `POST`.",
      required: false
    )
    parameter(
      "StatusCallback",
      "*Request Body Parameter*: The URL we should call using the `status_callback_method` to send status information to your application.",
      required: false
    )
    parameter(
      "StatusCallbackMethod",
      "*Request Body Parameter*: The HTTP method we should use to call `status_callback`. Can be: `GET` or `POST` and defaults to `POST`.",
      required: false
    )

    # https://www.twilio.com/docs/phone-numbers/api/incomingphonenumber-resource#update-an-incomingphonenumber-resource
    example "6. Update IncomingPhoneNumber to use a new Voice URL" do
      explanation <<~HEREDOC
        You will receive a HTTP request to this URL when a call comes in to your phone number.
      HEREDOC

      incoming_phone_number = create(:incoming_phone_number)

      set_twilio_api_authorization_header(incoming_phone_number.account)
      do_request(
        AccountSid: incoming_phone_number.account.id,
        Sid: incoming_phone_number.id,
        VoiceUrl: "https://www.your-voice-url.com/example"
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/incoming_phone_number")
      expect(json_response).to include(
        "voice_url" => "https://www.your-voice-url.com/example"
      )
    end
  end


  delete "https://api.somleng.org/2010-04-01/Accounts/:AccountSid/IncomingPhoneNumbers/:Sid" do
    parameter(
      "AccountSid",
      "*Path Parameter*: The SID of the Account that created the IncomingPhoneNumber resource to delete.",
    )
    parameter(
      "Sid",
      "*Path Parameter*: The SID of the IncomingPhoneNumber resource to delete.",
    )

    # https://www.twilio.com/docs/phone-numbers/api/incomingphonenumber-resource#delete-an-incomingphonenumber-resource
    example "7. Delete an IncomingPhoneNumber" do
      explanation <<~HEREDOC
        Release this phone number from your account.
        We will no longer answer calls to this number, and you will stop being billed the monthly phone number fee.
        The phone number will be recycled and potentially given to another customer, so use with care.
      HEREDOC

      incoming_phone_number = create(:incoming_phone_number)

      set_twilio_api_authorization_header(incoming_phone_number.account)
      do_request(
        AccountSid: incoming_phone_number.account.id,
        Sid: incoming_phone_number.id
      )

      expect(response_status).to eq(204)
      expect(incoming_phone_number.reload).to have_attributes(
        status: "released",
        released_at: be_present,
        phone_number_plan: have_attributes(
          status: "canceled",
          canceled_at: be_present
        )
      )
    end
  end
end
