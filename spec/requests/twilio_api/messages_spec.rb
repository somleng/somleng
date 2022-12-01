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
    # https://www.twilio.com/docs/sms/api/message-resource#create-a-message-resource

    explanation <<~HEREDOC
      To send a new outgoing message, make an HTTP POST to this Messages list resource URI.

      When creating a new message via the API,
      you must include the `To` parameter. This value should be either a destination phone number.
      You also need to pass a `Body` containing the message's content.

      You must also include either the `From` parameter or `MessagingServiceSid` parameter.
      You may use `MessagingServiceSid` if sending your message with a messaging service.
      Alternatively, you can choose a specific number in a messaging service to set as the `From`.

      There is a slight difference in how the API responds based on the parameter you include:

      * From: The API will validate the phone numbers synchronously.
        The API returns either a `queued` status or an error.
      * MessagingServiceSid: the API will first return a status of `accepted`.
        It then determines the optimal `From` phone number.
        Any delivery errors will be sent asynchronously to your StatusCallback URL.

      If the body of your message is more than 160 GSM-7 characters (or 70 UCS-2 characters),
      we will send the message as a segmented SMS.
    HEREDOC

    parameter(
      "From",
      "A phone number in E.164 format. Required if MessagingServiceSid is not passed",
      required: false,
      example: "+855716788999"
    )

    parameter(
      "MessagingServiceSid",
      "The SID of the Messaging Service you want to associate with the Message. Set this parameter to use the Messaging Service Settings you have configured and leave the `From` parameter empty. When only this parameter is set, we will select the `From` phone number for delivery.",
      required: false,
      example: SecureRandom.uuid
    )

    parameter(
      "Body",
      "The text of the message you want to send. Can be up to 1,600 characters in length.",
      required: true,
      example: "Hello World"
    )
    parameter(
      "To",
      "The destination phone number in E.164 format",
      required: true,
      example: "+855716788123"
    )
    parameter(
      "StatusCallback",
      "The URL we should call to send status information to your application. If specified, we POST these message status changes to the URL: `queued`, `failed`, `sent`, `delivered`, or `undelivered`. Somleng will POST its standard request parameters as well as some additional parameters including `MessageSid`, `MessageStatus`, and `ErrorCode`. URLs must contain a valid hostname (underscores are not permitted).",
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
      "ValidityPeriod",
      "How long in seconds the message can remain in our outgoing message queue. After this period elapses, the message fails and we call your status callback. Can be between 1 and the default value of 14,400 seconds. After a message has been accepted by a carrier, however, we cannot guarantee that the message will not be queued after this period. We recommend that this value be at least 5 seconds.",
      required: false,
      example: "60"
    )
    parameter(
      "SmartEncoded",
      "Whether to detect Unicode characters that have a similar GSM-7 character and replace them. Can be: `true` or `false`.",
      required: false,
      example: true
    )
    parameter(
      "ScheduleType",
      "Indicates your intent to schedule a message. Pass the value `fixed`` to schedule a message at a fixed time.",
      required: false,
      example: "fixed"
    )
    parameter(
      "SendAt",
      "The time that we will send the message. Must be in ISO 8601 format.",
      required: false,
      example: 5.days.from_now.iso8601
    )

    example "Create a Message" do
      account = create(:account)
      create(:sms_gateway, carrier: account.carrier)
      create(:phone_number, :configured, account:, number: "855716788999", carrier: account.carrier)

      set_twilio_api_authorization_header(account)

      perform_enqueued_jobs do
        do_request(
          account_sid: account.id,
          "To" => "+855716788123",
          "From" => "+855716788999",
          "Body" => "Hello World"
        )
      end

      expect(response_status).to eq(201)
      expect(response_body).to match_api_response_schema("twilio_api/message")
      expect(json_response.fetch("status")).to eq("queued")
    end

    example "Schedule a Message" do
      account = create(:account)
      create(:sms_gateway, carrier: account.carrier)
      messaging_service = create(:messaging_service, account:, carrier: account.carrier)
      create(
        :phone_number,
        :configured,
        messaging_service:,
        account:,
        carrier: account.carrier
      )

      set_twilio_api_authorization_header(account)

      travel_to(Time.current) do
        do_request(
          account_sid: account.id,
          "To" => "+855716788123",
          "Body" => "Hello World",
          "SendAt" => 5.days.from_now.iso8601,
          "ScheduleType" => "fixed",
          "MessagingServiceSid" => messaging_service.id
        )

        expect(response_status).to eq(201)
        expect(response_body).to match_api_response_schema("twilio_api/message")
        expect(json_response.fetch("status")).to eq("queued")
        expect(ScheduledJob).to have_been_enqueued.with(
          OutboundMessageJob.to_s,
          any_args,
          wait_until: 5.days.from_now
        )
      end
    end

    example "Handles invalid requests", document: false do
      account = create(:account)
      create(:sms_gateway, carrier: account.carrier)

      set_twilio_api_authorization_header(account)
      do_request(
        account_sid: account.id,
        "To" => "+855716788123",
        "From" => "+855716788999",
        "Body" => "Hello World"
      )

      expect(response_status).to eq(422)
      expect(response_body).to match_api_response_schema("twilio_api/api_errors")
      expect(json_response).to eq(
        "message" => "The 'From' phone number provided is not a valid message-capable phone number for this destination.",
        "status" => 422,
        "code" => 21_606,
        "more_info" => "https://www.twilio.com/docs/errors/21606"
      )
    end
  end

  get "https://api.somleng.org/2010-04-01/Accounts/:account_sid/Messages/:sid" do
    # https://www.twilio.com/docs/sms/api/message-resource#fetch-a-message-resource

    example "Fetch a message" do
      account = create(:account)
      message = create(:message, account:)

      set_twilio_api_authorization_header(account)
      do_request(account_sid: account.id, sid: message.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/message")
    end
  end

  post "https://api.somleng.org/2010-04-01/Accounts/:account_sid/Messages/:sid" do
    # https://www.twilio.com/docs/sms/api/message-resource#update-a-message-resource

    explanation <<~HEREDOC
      Updates the body of a Message resource.

      This action is primarily used to redact messages: to do so, POST to the above URI and set the
      `Body` parameter as an empty string: "".
      This will allow you to effectively redact the text of a message
      while keeping the other message resource properties intact.
    HEREDOC

    parameter(
      "AccountSid",
      "The SID of the Account that created the Message resources to update.",
      required: true
    )

    parameter(
      "Sid",
      "The ID that uniquely identifies the Message resource to update.",
      required: true
    )

    parameter(
      "Body",
      "The text of the message you want to send. Can be up to 1,600 characters in length.",
      required: false,
      example: ""
    )

    example "Redact a message" do
      account = create(:account)
      message = create(:message, :sent, account:)

      set_twilio_api_authorization_header(account)
      do_request(
        account_sid: account.id,
        sid: message.id,
        "Body" => ""
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/message")
      expect(json_response.fetch("body")).to eq("")
    end
  end

  delete "https://api.somleng.org/2010-04-01/Accounts/:account_sid/Messages/:sid" do
    # https://www.twilio.com/docs/sms/api/message-resource#update-a-message-resource

    explanation <<~HEREDOC
      Deletes a message record from your account. Once the record is deleted, it will no longer appear in the API and Account Portal logs.

      If successful, returns `HTTP 204` (No Content) with no body.

      Attempting to delete an in-progress message record will result in an error.
    HEREDOC

    parameter(
      "AccountSid",
      "The SID of the Account that created the Message resources to delete.",
      required: true
    )

    parameter(
      "Sid",
      "The ID that uniquely identifies the Message resource to delete.",
      required: true
    )

    example "Delete a message" do
      account = create(:account)
      message = create(:message, :sent, account:)
      create(:interaction, message:, account:, carrier: account.carrier)

      set_twilio_api_authorization_header(account)
      do_request(account_sid: account.id, sid: message.id)

      expect(response_status).to eq(204)
      expect(account.interactions.count).to eq(1)
    end

    example "Does not delete in-progress messages", document: false do
      account = create(:account)
      message = create(:message, :initiated, account:)

      set_twilio_api_authorization_header(account)
      do_request(account_sid: account.id, sid: message.id)

      expect(response_status).to eq(422)
      expect(response_body).to match_api_response_schema("twilio_api/api_errors")
      expect(json_response).to eq(
        "message" => "Cannot delete this resource before it is complete",
        "status" => 422,
        "code" => 20_009,
        "more_info" => "https://www.twilio.com/docs/errors/20009"
      )
    end
  end
end
