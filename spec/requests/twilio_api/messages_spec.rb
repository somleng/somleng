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
