require "rails_helper"

RSpec.resource "Messages", document: :twilio_api do
  header("Content-Type", "application/x-www-form-urlencoded")

  get "https://api.somleng.org/2010-04-01/Accounts/:account_sid/Messages" do
    example "List messages" do
      account = create(:account)
      message = create(:message, account:)
      _other_message = create(:message)

      set_twilio_api_authorization_header(account)
      do_request(account_sid: account.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_collection_schema("twilio_api/message")
      expect(json_response.fetch("messages").pluck("sid")).to match_array([message.id])
    end
  end

  post "https://api.somleng.org/2010-04-01/Accounts/:account_sid/Messages" do
    parameter(
      "From",
      "A Somleng phone number in E.164 format",
      required: false,
      example: "+855716788999"
    )
    parameter(
      "Body",
      "The text of the message you want to send. Can be up to 1,600 characters in length.",
      required: true,
      example: "Hello World"
    )
    parameter(
      "To",
      "The destination phone number in E.164 format for SMS",
      required: true,
      example: "+855716788123"
    )
    parameter(
      "StatusCallback",
      "The URL we should call using the `status_callback_method` to send status information to your application. If specified, we POST these message status changes to the URL: `queued`, `failed`, `sent`, `delivered`, or `undelivered`. Somleng will POST its standard request parameters as well as some additional parameters including `MessageSid`, `MessageStatus`, and `ErrorCode`. URLs must contain a valid hostname (underscores are not permitted).",
      required: false,
      example: "https://example.com/status_callback"
    )
    parameter(
      "StatusCallbackMethod",
      "The HTTP method we should use when calling the `status_callback` URL. Can be: `GET` or `POST` and the default is `POST`.",
      required: false,
      example: "POST"
    )
    parameter(
      "Attempt",
      "Total number of attempts made ( including this ) to send out the message regardless of the provider used.",
      required: false,
      example: "5"
    )
    parameter(
      "ValidityPeriod",
      "How long in seconds the message can remain in our outgoing message queue. After this period elapses, the message fails and we call your status callback. Can be between 1 and the default value of 14,400 seconds. After a message has been accepted by a carrier, however, we cannot guarantee that the message will not be queued after this period. We recommend that this value be at least 5 seconds.",
      required: false,
      example: "60"
    )
    parameter(
      "ScheduleType",
      "Indicates your intent to schedule a message. Pass the value `fixed`` to schedule a message at a fixed time.",
      required: false,
      example: "fixed"
    )
    parameter(
      "SendAt",
      "The time that Somleng will send the message. Must be in ISO 8601 format.",
      required: false,
      example: 30.days.from_now.iso8601
    )

    # https://www.twilio.com/docs/sms/api/message-resource#create-a-message-resource
    example "Create a Message" do
      account = create(:account)
      create(:sms_gateway, carrier: account.carrier)

      set_twilio_api_authorization_header(account)

      do_request(
        account_sid: account.id,
        "To" => "+855716788123",
        "From" => "+855716788999",
        "Body" => "Hello World"
      )

      expect(response_status).to eq(201)
      expect(response_body).to match_api_response_schema("twilio_api/message")
    end

    example "Handles invalid requests", document: false do
      account = create(:account)

      set_twilio_api_authorization_header(account)
      do_request(
        account_sid: account.id,
        "To" => "+299221234",
        "From" => "1234",
        "Url" => "https://demo.twilio.com/docs/voice.xml"
      )

      expect(response_status).to eq(422)
      expect(response_body).to match_api_response_schema("twilio_api/api_errors")
      expect(json_response).to eq(
        "message" => "Calling this number is unsupported or the number is invalid",
        "status" => 422,
        "code" => 13_224,
        "more_info" => "https://www.twilio.com/docs/errors/13224"
      )
    end
  end

  get "https://api.somleng.org/2010-04-01/Accounts/:account_sid/Messages/:sid" do
    # https://www.twilio.com/docs/api/rest/call#instance-get

    example "Fetch a call" do
      account = create(:account)
      phone_call = create(:phone_call, account:)

      set_twilio_api_authorization_header(account)
      do_request(account_sid: account.id, sid: phone_call.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/call")
    end
  end
end
