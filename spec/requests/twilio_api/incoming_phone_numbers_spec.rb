require "rails_helper"

RSpec.resource "Incoming Phone Numbers", document: :twilio_api do
  # https://www.twilio.com/docs/phone-numbers/api/incomingphonenumber-resource

  explanation <<~HEREDOC
    An `IncomingPhoneNumber` resource represents a phone number provisioned to your account.
    The IncomingPhoneNumbers list resource represents an account's phone numbers. You can `POST` to the list resource to provision a new number. To find a new number to provision use the subresources of the [Available Phone Numbers] resource.
  HEREDOC

  get "https://api.somleng.org/2010-04-01/Accounts/:account_sid/IncomingPhoneNumbers" do
    # https://www.twilio.com/docs/phone-numbers/api/incomingphonenumber-resource#read-multiple-incomingphonenumber-resources

    explanation <<~HEREDOC
      List all IncomingPhoneNumber resources for your account
    HEREDOC

    parameter(
      :PhoneNumber,
      "The phone number of the IncomingPhoneNumber resources to filter.",
      required: false
    )

    example "Read a list of Incoming Phone Numbers" do
      incoming_phone_number = create(
        :incoming_phone_number,
        number: "12513095500"
      )
      create(:incoming_phone_number, number: "12513095501", account: incoming_phone_number.account)

      set_twilio_api_authorization_header(incoming_phone_number.account)
      do_request(account_sid: incoming_phone_number.account_id, PhoneNumber: "+12513095500")

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
      do_request(account_sid: account.id, PhoneNumber: "invalid")

      expect(response_status).to eq(400)
      expect(response_body).to match_api_response_schema("twilio_api/api_errors")
    end
  end

  get "https://api.somleng.org/2010-04-01/Accounts/:account_sid/IncomingPhoneNumbers/:sid" do
    # https://www.twilio.com/docs/phone-numbers/api/incomingphonenumber-resource#fetch-an-incomingphonenumber-resource

    explanation <<~HEREDOC
      Fetch an IncomingPhoneNumber
    HEREDOC

    example "Fetch an IncomingPhoneNumber resource" do
      incoming_phone_number = create(:incoming_phone_number, number: "12513095500")

      set_twilio_api_authorization_header(incoming_phone_number.account)
      do_request(account_sid: incoming_phone_number.account.id, sid: incoming_phone_number.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/incoming_phone_number")
    end
  end

  post "https://api.somleng.org/2010-04-01/Accounts/:account_sid/IncomingPhoneNumbers" do
    # https://www.twilio.com/docs/phone-numbers/api/incomingphonenumber-resource#fetch-an-incomingphonenumber-resource

    explanation <<~HEREDOC
      Create an IncomingPhoneNumber resource
      You will be charged when you provision the number, and the number will appear on the Phone Numbers page in the console.
    HEREDOC

    parameter(
      :PhoneNumber,
      "The phone number to purchase specified in E.164 format.",
      required: true
    )

    parameter(
      :SmsUrl,
      "The URL we should call when the new phone number receives an incoming SMS message.",
      required: false
    )

    parameter(
      :SmsMethod,
      "The HTTP method that we should use to call `sms_url`. Can be: `GET` or `POST` and defaults to `POST`.",
      required: false
    )

    parameter(
      :VoiceUrl,
      "The URL that we should call to answer a call to the new phone number.",
      required: false
    )

    parameter(
      :VoiceMethod,
      "The HTTP method that we should use to call `voice_url`. Can be: `GET` or `POST` and defaults to `POST`.",
      required: false
    )

    parameter(
      :StatusCallback,
      "The URL we should call using the `status_callback_method` to send status information to your application.",
      required: false
    )

    parameter(
      :StatusCallbackMethod,
      "The HTTP method we should use to call `status_callback`. Can be: `GET` or `POST` and defaults to `POST`.",
      required: false
    )

    example "Provision a Phone Number" do
      account = create(:account)
      create(:phone_number, number: "12513095500", carrier: account.carrier)

      set_twilio_api_authorization_header(account)
      do_request(
        account_sid: account.id,
        PhoneNumber: "+12513095500",
      )

      expect(response_status).to eq(201)
      expect(response_body).to match_api_response_schema("twilio_api/incoming_phone_number")
      expect(json_response).to include(
        "phone_number" => "+12513095500"
      )
    end

    example "Provision a Phone Number with a Voice URL" do
      account = create(:account)
      create(:phone_number, number: "12513095500", carrier: account.carrier)

      set_twilio_api_authorization_header(account)
      do_request(
        account_sid: account.id,
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

    example "Provision a Phone Number with an SMS URL" do
      account = create(:account)
      create(:phone_number, number: "12513095500", carrier: account.carrier)

      set_twilio_api_authorization_header(account)
      do_request(
        account_sid: account.id,
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
        account_sid: account.id,
        PhoneNumber: "+12513095500",
      )

      expect(response_status).to eq(422)
      expect(response_body).to match_api_response_schema("twilio_api/api_errors")
    end
  end

  post "https://api.somleng.org/2010-04-01/Accounts/:account_sid/IncomingPhoneNumbers/:sid" do
    # https://www.twilio.com/docs/phone-numbers/api/incomingphonenumber-resource#update-an-incomingphonenumber-resource

    parameter(
      :SmsUrl,
      "The URL we should call when the new phone number receives an incoming SMS message.",
      required: false
    )

    parameter(
      :SmsMethod,
      "The HTTP method that we should use to call `sms_url`. Can be: `GET` or `POST` and defaults to `POST`.",
      required: false
    )

    parameter(
      :VoiceUrl,
      "The URL that we should call to answer a call to the new phone number.",
      required: false
    )

    parameter(
      :VoiceMethod,
      "The HTTP method that we should use to call `voice_url`. Can be: `GET` or `POST` and defaults to `POST`.",
      required: false
    )

    parameter(
      :StatusCallback,
      "The URL we should call using the `status_callback_method` to send status information to your application.",
      required: false
    )

    parameter(
      :StatusCallbackMethod,
      "The HTTP method we should use to call `status_callback`. Can be: `GET` or `POST` and defaults to `POST`.",
      required: false
    )

    example "Update IncomingPhoneNumber to use a new Voice URL" do
      incoming_phone_number = create(:incoming_phone_number)

      set_twilio_api_authorization_header(incoming_phone_number.account)
      do_request(
        account_sid: incoming_phone_number.account.id,
        sid: incoming_phone_number.id,
        VoiceUrl: "https://www.your-voice-url.com/example"
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/incoming_phone_number")
      expect(json_response).to include(
        "voice_url" => "https://www.your-voice-url.com/example"
      )
    end
  end


  delete "https://api.somleng.org/2010-04-01/Accounts/:account_sid/IncomingPhoneNumbers/:sid" do
    # https://www.twilio.com/docs/phone-numbers/api/incomingphonenumber-resource#delete-an-incomingphonenumber-resource

    explanation <<~HEREDOC
      Release this phone number from your account.
      We will no longer answer calls to this number, and you will stop being billed the monthly phone number fee.
      The phone number will be recycled and potentially given to another customer, so use with care.
    HEREDOC

    example "Delete an IncomingPhoneNumber" do
      incoming_phone_number = create(:incoming_phone_number)

      set_twilio_api_authorization_header(incoming_phone_number.account)
      do_request(
        account_sid: incoming_phone_number.account.id,
        sid: incoming_phone_number.id
      )

      expect(response_status).to eq(204)
      expect(incoming_phone_number.reload).to have_attributes(
        status: "inactive",
        phone_number_plan: have_attributes(
          status: "canceled",
          canceled_at: be_present
        )
      )
    end
  end
end
