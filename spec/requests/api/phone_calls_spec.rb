require "rails_helper"

RSpec.resource "Phone Calls" do
  header("Content-Type", "application/x-www-form-urlencoded")

  post "/2010-04-01/Accounts/:account_sid/Calls" do
    parameter(
      "To",
      "The phone number to call.",
      required: true
    )
    parameter(
      "From",
      "The phone number to use as the caller id",
      required: true
    )
    parameter(
      "Url",
      "The absolute URL that returns the TwiML instructions for the call. We will call this URL using the `method` when the call connects.",
      required: true
    )
    parameter(
      "Method",
      "The HTTP method we should use when calling the url parameter's value. Can be: `GET` or `POST` and the default is `POST`.",
      required: false
    )
    parameter(
      "StatusCallback",
      "The URL we should call using the `status_callback_method` to send status information to your application. URLs must contain a valid hostname (underscores are not permitted).",
      required: false
    )
    parameter(
      "StatusCallbackMethod",
      "The HTTP method we should use when calling the `status_callback` URL. Can be: `GET` or `POST` and the default is `POST`.",
      required: false
    )

    # https://www.twilio.com/docs/api/rest/making-calls
    example "Create a call" do
      account = create(:account)

      set_api_authorization_header(account)
      do_request(
        account_sid: account.id,
        "To" => "+85512888999",
        "From" => "2442",
        "Url" => "https://demo.twilio.com/docs/voice.xml"
      )

      expect(response_status).to eq(201)
      expect(response_body).to match_api_response_schema(:phone_call)
    end

    example "Handles invalid requests", document: false do
      account = create(:account)

      set_api_authorization_header(account)
      do_request(account_sid: account.id)

      expect(response_status).to eq(422)
      expect(response_body).to match_api_response_schema(:api_errors)
    end
  end

  get "/2010-04-01/Accounts/:account_sid/Calls/:call_sid" do
    # https://www.twilio.com/docs/api/rest/call#instance-get

    it "Fetch a call" do
      account = create(:account)
      phone_call = create(:phone_call, account: account)

      set_api_authorization_header(account)
      do_request(account_sid: account.id, call_sid: phone_call.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema(:phone_call)
    end
  end
end
