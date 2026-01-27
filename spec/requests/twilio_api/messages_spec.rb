require "rails_helper"

RSpec.resource "Messages", document: :twilio_api do
  header("Content-Type", "application/x-www-form-urlencoded")

  post "https://api.somleng.org/2010-04-01/Accounts/:AccountSid/Messages" do
    parameter(
      "AccountSid",
      "*Path Parameter*: The SID of the Account creating the Message resource.",
    )
    parameter(
      "From",
      "*Request Body Parameter*: A phone number in E.164 format. Required if MessagingServiceSid is not passed",
      required: false,
      example: "+855716788999"
    )
    parameter(
      "MessagingServiceSid",
      "*Request Body Parameter*: The SID of the Messaging Service you want to associate with the Message. Set this parameter to use the Messaging Service Settings you have configured and leave the `From` parameter empty. When only this parameter is set, we will select the `From` phone number for delivery.",
      required: false,
      example: SecureRandom.uuid
    )
    parameter(
      "Body",
      "*Request Body Parameter*: The text of the message you want to send. Can be up to 1,600 characters in length.",
      required: true,
      example: "Hello World"
    )
    parameter(
      "To",
      "*Request Body Parameter*: The destination phone number in E.164 format",
      required: true,
      example: "+855716788123"
    )
    parameter(
      "StatusCallback",
      "*Request Body Parameter*: The URL we should call to send status information to your application. If specified, we POST these message status changes to the URL: `queued`, `failed`, `sent`, `delivered`, or `undelivered`. Somleng will POST its standard request parameters as well as some additional parameters including `MessageSid`, `MessageStatus`, and `ErrorCode`. URLs must contain a valid hostname (underscores are not permitted).",
      required: false,
      example: "https://example.com/status_callback"
    )
    parameter(
      "StatusCallbackMethod",
      "*Request Body Parameter*: The HTTP method we should use when calling the `status_callback` URL. Can be: `GET` or `POST` and the default is `POST`.",
      required: false,
      example: "POST"
    )
    parameter(
      "ValidityPeriod",
      "*Request Body Parameter*: How long in seconds the message can remain in our outgoing message queue. After this period elapses, the message fails and we call your status callback. Can be between 1 and the default value of 14,400 seconds. After a message has been accepted by a carrier, however, we cannot guarantee that the message will not be queued after this period. We recommend that this value be at least 5 seconds.",
      required: false,
      example: "60"
    )
    parameter(
      "SmartEncoded",
      "*Request Body Parameter*: Whether to detect Unicode characters that have a similar GSM-7 character and replace them. Can be: `true` or `false`.",
      required: false,
      example: true
    )
    parameter(
      "ScheduleType",
      "*Request Body Parameter*: Indicates your intent to schedule a message. Pass the value `fixed` to schedule a message at a fixed time.",
      required: false,
      example: "fixed"
    )
    parameter(
      "SendAt",
      "*Request Body Parameter*: The time that we will send the message. Must be in ISO 8601 format.",
      required: false,
      example: 5.days.from_now.iso8601
    )

    # https://www.twilio.com/docs/messaging/api/message-resource#send-an-sms-message-1
    example "01. Send an SMS Message" do
      explanation <<~HEREDOC
        The example below shows how to create a Message resource with an SMS recipient.
        Sending this `POST` request creates text message from `+855716788999` (a phone number belonging to the Account sending the request) to `+855716788123`. The content of the text message is `Hello World`.
      HEREDOC

      carrier = create(:carrier)
      account = create(:account, :billing_enabled, carrier:)
      create(:sms_gateway, carrier: account.carrier)
      create(:incoming_phone_number, account:, number: "855716788999")
      create(:tariff_plan_subscription, account:, plan_category: :outbound_messages)
      stub_rating_engine_request(result: build(:rating_engine_cost_response))

      set_twilio_api_authorization_header(account)

      perform_enqueued_jobs do
        do_request(
          AccountSid: account.id,
          "To" => "+855716788123",
          "From" => "+855716788999",
          "Body" => "Hello World"
        )
      end

      expect(response_status).to eq(201)
      expect(response_body).to match_api_response_schema("twilio_api/message")
      expect(json_response).to include(
        "status" => "queued",
        "to" => "+855716788123",
        "from" => "+855716788999",
        "body" => "Hello World"
      )
    end

    # https://www.twilio.com/docs/messaging/api/message-resource#send-a-message-with-a-messaging-service
    example "02. Send a message with a Messaging Service" do
      explanation <<~HEREDOC
        When sending a message with a Messaging Service, you must provide a **recipient** via the `To` parameter and **content** via the `Body` parameter. In addition, you must provide the `MessagingServiceSid`.

        If you provide a `MessagingServiceSid` and no `From` parameter, the optimal `From` value wil be determined from your Sender Pool. In this case, the Message resource's initial `Status` value is `accepted`.

        Optionally, you can provide a` MessagingServiceSid` *and* a `From` parameter. The `From` parameter must be a sender from your Messaging Service's Sender Pool. In this case, the Message resource's initial `Status` value is `queued`.

        With Messaging Services, you can also schedule messages to be sent in the future.
      HEREDOC

      account = create(:account)
      create(:sms_gateway, carrier: account.carrier)
      messaging_service = create(
        :messaging_service,
        account:,
        carrier: account.carrier,
        status_callback_url: "https://www.example.com/message_status_callback"
      )
      create(:incoming_phone_number, messaging_service:, account:)
      stub_request(:post, "https://www.example.com/message_status_callback")

      set_twilio_api_authorization_header(account)

      perform_enqueued_jobs do
        do_request(
          AccountSid: account.id,
          "To" => "+855716788123",
          "MessagingServiceSid" => messaging_service.id,
          "Body" => "Hello World"
        )
      end

      expect(response_status).to eq(201)
      expect(response_body).to match_api_response_schema("twilio_api/message")
      expect(json_response).to include(
        "status" => "accepted",
        "from" => nil
      )
      expect_status_callback_request(
        to: "https://www.example.com/message_status_callback",
        with_status: "queued"
      )
    end

    example "03. Schedule a Message" do
      explanation <<~HEREDOC
        The example below shows how to schedule a Message to be sent in the future.
      HEREDOC

      account = create(:account)
      create(:sms_gateway, carrier: account.carrier)
      messaging_service = create(:messaging_service, account:, carrier: account.carrier)
      create(
        :incoming_phone_number,
        messaging_service:,
        account:
      )

      set_twilio_api_authorization_header(account)

      travel_to(Time.current) do
        do_request(
          AccountSid: account.id,
          "To" => "+855716788123",
          "Body" => "Hello World",
          "SendAt" => 5.days.from_now.iso8601,
          "ScheduleType" => "fixed",
          "MessagingServiceSid" => messaging_service.id
        )

        expect(response_status).to eq(201)
        expect(response_body).to match_api_response_schema("twilio_api/message")
        expect(json_response).to include(
          "status" => "scheduled"
        )
        expect(ScheduledJob).to have_been_enqueued.with(
          QueueOutboundMessage.to_s,
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
        AccountSid: account.id,
        "To" => "+855716788123",
        "From" => "+855716788999",
        "Body" => "Hello World"
      )

      expect(response_status).to eq(422)
      expect(response_body).to match_api_response_schema("twilio_api/api_errors")
      expect(json_response).to eq(
        "message" => "The 'From' phone number provided is not a valid message-capable phone number for this destination.",
        "status" => 422,
        "code" => "21606",
        "more_info" => "https://www.twilio.com/docs/errors/21606"
      )
    end
  end

  get "https://api.somleng.org/2010-04-01/Accounts/:AccountSid/Messages/:Sid" do
    parameter(
      "AccountSid",
      "*Path Parameter*: The SID of the Account associated with the Message resource.",
    )
    parameter(
      "Sid",
      "*Path Parameter*: The SID of the Message resource to be fetched.",
    )

    # https://www.twilio.com/docs/sms/api/message-resource#fetch-a-message-resource
    example "04. Fetch a Message" do
      explanation <<~HEREDOC
        Returns a single Message resource specified by the provided Message `SID`.
      HEREDOC

      account = create(:account)
      message = create(:message, account:)

      set_twilio_api_authorization_header(account)
      do_request(AccountSid: account.id, Sid: message.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/message")
    end
  end

  get "https://api.somleng.org/2010-04-01/Accounts/:AccountSid/Messages" do
    parameter(
      "AccountSid",
      "*Path Parameter*: The SID of the Account associated with the Message resources.",
    )

    # https://www.twilio.com/docs/messaging/api/message-resource#read-multiple-message-resources
    example "05. List all messages" do
      explanation <<~HEREDOC
        Returns a list of all Message resources associated with your Account
      HEREDOC

      account = create(:account)
      message = create(:message, account:)
      _other_message = create(:message)

      set_twilio_api_authorization_header(account)
      do_request(AccountSid: account.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_collection_schema("twilio_api/message")
      expect(json_response.fetch("messages").pluck("sid")).to contain_exactly(message.id)
    end
  end

  post "https://api.somleng.org/2010-04-01/Accounts/:AccountSid/Messages/:Sid" do
    parameter(
      "AccountSid",
      "*Path Parameter*: The SID of the Account that created the Message resources to update.",
    )
    parameter(
      "Sid",
      "*Path Parameter*: The SID of the Message resource to be updated.",
    )
    parameter(
      "Body",
      "*Request Body Parameter*: The new body of the Message resource. To redact the text content of a Message, this parameter's value must be an empty string",
      required: false,
      example: ""
    )
    parameter(
      "Status",
      "*Request Body Parameter*: Set as `canceled` to prevent a not-yet-sent Message from being sent. Can be used to cancel sending a scheduled Message.",
      required: false,
      example: "canceled"
    )

    # https://www.twilio.com/docs/messaging/api/message-resource#redact-the-body-of-a-message-resource
    example "06. Redact a message" do
      explanation <<~HEREDOC
        This action can be used to redact messages: to do so, POST to the above URI and set the
        `Body` parameter as an empty string: "". This will allow you to effectively redact the text of a message
        while keeping the other message resource properties intact.
      HEREDOC

      account = create(:account)
      message = create(:message, :sent, account:)

      set_twilio_api_authorization_header(account)
      do_request(
        AccountSid: account.id,
        Sid: message.id,
        "Body" => ""
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/message")
      expect(json_response.fetch("body")).to eq("")
    end

    example "07. Cancel a scheduled message" do
      explanation <<~HEREDOC
        Before you use this functionality:

        1. Ensure the status value of canceled is spelled with one "l", (**canceled**) and not two (cancelled).
        2. Ensure that you store the `MessageSid` of the messages you schedule. You need to reference the `MessageSid` for each message cancelation request.
        3. There is no bulk cancelation. If you'd like to cancel multiple messages, you must send in a cancelation request for each message and reference the `MessageSid`.
        4. There is a new status callback event for `Canceled`. You can continue to receive existing callback events by including the optional `StatusCallBack` parameter in the message request.
     HEREDOC

      account = create(:account)
      message = create(
        :message,
        :scheduled,
        account:,
        status_callback_url: "https://www.example.com/message_status_callback"
      )
      stub_request(:post, "https://www.example.com/message_status_callback")

      set_twilio_api_authorization_header(account)
      perform_enqueued_jobs do
        do_request(
          AccountSid: account.id,
          Sid: message.id,
          "Status" => "canceled"
        )
      end

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/message")
      expect(json_response.fetch("status")).to eq("canceled")
      expect_status_callback_request(
        to: "https://www.example.com/message_status_callback",
        with_status: "canceled"
      )
    end
  end

  delete "https://api.somleng.org/2010-04-01/Accounts/:AccountSid/Messages/:Sid" do
    explanation <<~HEREDOC
      Deletes a message record from your account. Once the record is deleted, it will no longer appear in the API and Account Portal logs.

      If successful, returns `HTTP 204` (No Content) with no body.

      Attempting to delete an in-progress message record will result in an error.
    HEREDOC

    parameter(
      "AccountSid",
      "*Path Parameter*: The SID of the Account associated with the Message resource.",
    )
    parameter(
      "Sid",
      "*Path Parameter*: The SID of the Message resource you wish to delete.",
    )

    # https://www.twilio.com/docs/sms/api/message-resource#update-a-message-resource
    example "08. Delete a Message" do
      explanation <<~HEREDOC
        To delete a Message resource, send a `DELETE` request to the Message resource's URI.

        If the `DELETE` request is successful, the response status code is `HTTP 204 (No Content)`.

        A deleted Message resource no longer appears in your Account's Messaging logs. Deleted messages cannot be recovered.
      HEREDOC

      account = create(:account)
      message = create(:message, :sent, account:)
      create(:interaction, message:, account:, carrier: account.carrier)

      set_twilio_api_authorization_header(account)
      do_request(AccountSid: account.id, Sid: message.id)

      expect(response_status).to eq(204)
      expect(account.interactions.count).to eq(1)
    end

    example "Does not delete in-progress messages", document: false do
      account = create(:account)
      message = create(:message, :queued, account:)

      set_twilio_api_authorization_header(account)
      do_request(AccountSid: account.id, Sid: message.id)

      expect(response_status).to eq(422)
      expect(response_body).to match_api_response_schema("twilio_api/api_errors")
      expect(json_response).to eq(
        "message" => "Cannot delete this resource before it is complete",
        "status" => 422,
        "code" => "20009",
        "more_info" => "https://www.twilio.com/docs/errors/20009"
      )
    end
  end

  def expect_status_callback_request(to:, with_status:)
    expect(WebMock).to(
      have_requested(
        :post, to
      ).with { |request| request.body.include?("MessageStatus=#{with_status}") }
    )
  end
end
