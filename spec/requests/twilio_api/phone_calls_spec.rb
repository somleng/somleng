require "rails_helper"

RSpec.resource "Phone Calls", document: :twilio_api do
  header("Content-Type", "application/x-www-form-urlencoded")

  post "https://api.somleng.org/2010-04-01/Accounts/:AccountSid/Calls" do
    parameter(
      "AccountSid",
      "*Path Parameter*: The SID of the Account that will create the resource."
    )
    parameter(
      "To",
      "*Request Body Parameter*: The phone number to call.",
      required: true,
      example: "+18288822789"
    )
    parameter(
      "From",
      "*Request Body Parameter*: The phone number to use as the caller id.",
      required: true,
      example: "+16189124649"
    )
    parameter(
      "Url",
      "*Request Body Parameter*: The absolute URL that returns the TwiML instructions for the call. We will call this URL using the `method` when the call connects.",
      required: false,
      example: "https://demo.twilio.com/docs/voice.xml"
    )
    parameter(
      "Method",
      "The HTTP method we should use when calling the url parameter's value. Can be: `GET` or `POST` and the default is `POST`.",
      required: false,
      example: "GET"
    )
    parameter(
      "Twiml",
      "*Request Body Parameter*: TwiML instructions for the call to be used without fetching TwiML from `Url` parameter. If both `Twiml` and `Url` are provided then `Twiml` parameter will be ignored.",
      required: false,
      example: "<Response><Say>Ahoy there!</Say></Response>"
    )
    parameter(
      "StatusCallback",
      "*Request Body Parameter*: The URL we should call using the `status_callback_method` to send status information to your application. URLs must contain a valid hostname (underscores are not permitted).",
      required: false,
      example: "https://example.com/status_callback"
    )
    parameter(
      "StatusCallbackMethod",
      "*Request Body Parameter*: The HTTP method we should use when calling the `status_callback` URL. Can be: `GET` or `POST` and the default is `POST`.",
      required: false,
      example: "POST"
    )

    # https://www.twilio.com/docs/voice/api/call-resource#create-a-call-resource
    example "01. Create a call" do
      explanation <<~HEREDOC
        Calls can be made via the REST API to phone numbers. To place a new outbound call, make an `HTTP POST` request to your account's Call resource.
      HEREDOC

      account = create(:account, :billing_enabled)
      create(:incoming_phone_number, number: "12513095500", account:)
      create(:sip_trunk, carrier: account.carrier, region: :hydrogen)
      create(
        :tariff_plan_subscription,
        account:,
        plan: create(
          :tariff_plan, :configured, :outbound_calls,
          carrier: account.carrier,
          destination_prefixes: [ "299" ]
        )
      )
      stub_rating_engine_request(result: 100)
      stub_switch_request(region: :hydrogen)

      set_twilio_api_authorization_header(account)
      perform_enqueued_jobs do
        do_request(
          AccountSid: account.id,
          "To" => "+299221234",
          "From" => "+12513095500",
          "Url" => "https://demo.twilio.com/docs/voice.xml"
        )
      end

      expect(response_status).to eq(201)
      expect(response_body).to match_api_response_schema("twilio_api/call")
    end

    example "Handles invalid requests", document: false do
      account = create(:account)
      create(:sip_trunk, carrier: account.carrier)

      set_twilio_api_authorization_header(account)
      do_request(
        AccountSid: account.id,
        "To" => "+299221234",
        "From" => "1234",
        "Url" => "https://demo.twilio.com/docs/voice.xml"
      )

      expect(response_status).to eq(422)
      expect(response_body).to match_api_response_schema("twilio_api/api_errors")
      expect(json_response).to eq(
        "message" => "The source phone number provided is not yet verified for your account. You may only make calls from phone numbers that you've verified or purchased.",
        "status" => 422,
        "code" => "21210",
        "more_info" => "https://www.twilio.com/docs/errors/21210"
      )
    end
  end

  get "https://api.somleng.org/2010-04-01/Accounts/:AccountSid/Calls/:Sid" do
    parameter(
      "AccountSid",
      "*Path Parameter*: The SID of the Account that created the Call resource(s) to fetch."
    )
    parameter(
      "Sid",
      "*Path Parameter*: The SID of the Call resource to fetch."
    )

    # https://www.twilio.com/docs/voice/api/call-resource#fetch-a-call-resource
    example "02. Fetch a call" do
      explanation <<~HEREDOC
        This API call returns the Call resource of an individual call, identified by its `Sid`.
      HEREDOC

      account = create(:account)
      phone_call = create(:phone_call, account:)

      set_twilio_api_authorization_header(account)
      do_request(AccountSid: account.id, Sid: phone_call.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/call")
    end
  end

  get "https://api.somleng.org/2010-04-01/Accounts/:AccountSid/Calls" do
    parameter(
      "AccountSid",
      "*Path Parameter*: The SID of the Account that created the Call resource(s) to read."
    )

    # https://www.twilio.com/docs/voice/api/call-resource#read-multiple-call-resources
    example "03. List phone calls" do
      explanation <<~HEREDOC
        Return a list of phone calls made to and from an account, identified by its `AccountSid`.
      HEREDOC

      account = create(:account)
      phone_call = create(:phone_call, account:)
      _other_phone_call = create(:phone_call)

      set_twilio_api_authorization_header(account)
      do_request(AccountSid: account.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_collection_schema("twilio_api/call")
      expect(json_response.fetch("calls").pluck("sid")).to contain_exactly(phone_call.id)
    end
  end

  post "https://api.somleng.org/2010-04-01/Accounts/:AccountSid/Calls/:Sid" do
    parameter(
      "AccountSid",
      "*Path Parameter*: The SID of the Account that created the Call resource(s) to update."
    )
    parameter(
      "Sid",
      "*Path Parameter*: The ID that uniquely identifies the Call resource to update."
    )
    parameter(
      "Url",
      "*Request Body Parameter*: The absolute URL that returns the TwiML instructions for the call. We will call this URL using the method when the call connects.",
      required: false
    )
    parameter(
      "Method",
      "*Request Body Parameter*: The HTTP method we should use when calling the url. Can be: `GET` or `POST` and the default is `POST`.",
      required: false
    )
    parameter(
      "StatusCallback",
      "*Request Body Parameter*: The URL we should call using the `status_callback_method` to send status information to your application. URLs must contain a valid hostname (underscores are not permitted).",
      required: false
    )
    parameter(
      "StatusCallbackMethod",
      "*Request Body Parameter*: The HTTP method we should use when requesting the `status_callback` URL. Can be: `GET` or `POST` and the default is `POST`.",
      required: false
    )
    parameter(
      "Twiml",
      "*Request Body Parameter*: TwiML instructions for the call to be used without fetching Twiml from url. `Twiml` and `Url` parameters are mutually exclusive.",
      required: false
    )
    parameter(
      "Status",
      "*Request Body Parameter*: The new status of the resource. Can be: `canceled` or `completed`. Specifying `canceled` will attempt to hang up calls that are `queued` or `ringing`; however, it will not affect calls already in progress. Specifying `completed` will attempt to hang up a call even if it's already in progress.",
      required: false,
      example: "completed"
    )

    # https://www.twilio.com/docs/voice/api/call-resource?code-sample=code-update-a-call-resource-to-end-the-call&code-language=curl&code-sdk-version=json#update-a-call-in-progress-with-twiml
    example "04. Update a Call in progress with TwiML" do
      explanation <<~HEREDOC
        Updating a Call resource allows you to modify an active call.

        Real-time call modification allows you to interrupt an in-progress call and terminate it or have it begin processing TwiML from either a new URL or from the TwiML provided with modification.
        Call modification is useful for any application where you want to change the behavior of a running call asynchronously, e.g., hold music, call queues, transferring calls, or forcing a hangup.

        By sending an HTTP POST request to a specific Call instance, you can redirect a call that is in progress or you can terminate a call.

        This example interrupts an in-progress call and begins processing TwiML from a the TwiML provided.
      HEREDOC

      account = create(:account)
      phone_call = create(:phone_call, :answered, account:)
      stub_call_update(phone_call)
      set_twilio_api_authorization_header(account)

      perform_enqueued_jobs do
        do_request(
          AccountSid: account.id,
          Sid: phone_call.id,
          "Twiml" => "<Response><Say>Ahoy there</Say></Response>"
        )
      end

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/call")
    end

    # https://www.twilio.com/docs/voice/api/call-resource?code-sample=code-update-a-call-resource-to-end-the-call&code-language=curl&code-sdk-version=json#update-a--call-in-progress-with-url
    example "05. Update a Call in progress with URL" do
      explanation <<~HEREDOC
        This example interrupts an in-progress call and begins processing TwiML from a new URL.
      HEREDOC

      account = create(:account)
      phone_call = create(:phone_call, :answered, account:)
      stub_call_update(phone_call)
      set_twilio_api_authorization_header(account)

      perform_enqueued_jobs do
        do_request(
          AccountSid: account.id,
          Sid: phone_call.id,
          "Url" => "https://demo.twilio.com/docs/voice.xml",
          "Method" => "POST"
        )
      end

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/call")
    end

    # https://www.twilio.com/docs/voice/api/call-resource?code-sample=code-update-a-call-resource-to-end-the-call&code-language=curl&code-sdk-version=json#update-a-call-resource-to-end-the-call
    example "06. End a call" do
      explanation <<~HEREDOC
        This example interrupts an in-progress call and terminates it.
      HEREDOC

      account = create(:account)
      phone_call = create(:phone_call, :answered, account:)
      stub_call_update(phone_call)
      set_twilio_api_authorization_header(account)

      perform_enqueued_jobs do
        do_request(
          AccountSid: account.id,
          Sid: phone_call.id,
          "Status" => "completed"
        )
      end

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/call")
    end

    example "Cancel a call", document: false do
      account = create(:account)
      phone_call = create(:phone_call, :queued, account:)

      set_twilio_api_authorization_header(account)
      do_request(
        AccountSid: account.id,
        Sid: phone_call.id,
        "Status" => "canceled"
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/call")
      expect(json_response.fetch("status")).to eq("canceled")
    end

    example "Handles invalid requests", document: false do
      account = create(:account)
      phone_call = create(:phone_call, :completed, account:)

      set_twilio_api_authorization_header(account)
      do_request(
        AccountSid: account.id,
        Sid: phone_call.id,
        "Twiml" => "<Response><Say>Ahoy there</Say></Response>"
      )

      expect(response_status).to eq(422)
      expect(response_body).to match_api_response_schema("twilio_api/api_errors")
    end
  end

  def stub_call_update(phone_call)
    stub_request(:any, "http://#{phone_call.call_service_host}/calls/#{phone_call.external_id}")
  end

  def stub_switch_request(region: :hydrogen, external_call_id: SecureRandom.uuid, **response_params)
    response_params[:host] ||= "10.10.1.13"
    responses = Array(external_call_id).map { |id| { body: { id:, **response_params }.to_json } }
    stub_request(:post, "https://switch.#{region}.somleng.org/calls").to_return(responses)
  end
end
