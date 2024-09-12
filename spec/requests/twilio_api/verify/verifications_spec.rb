require "rails_helper"

RSpec.resource "Verifications", document: :twilio_api do
  post "https://verify.somleng.org/v2/Services/:ServiceSid/Verifications" do
    parameter(
      "ServiceSid",
      "*Path Parameter*: The SID of the verification Service to create the resource under.",
    )
    parameter(
      "To",
      "*Request Body Parameter*: The phone number or email to verify. Phone numbers must be in E.164 format.",
      required: true,
      example: "+85512334667"
    )
    parameter(
      "Channel",
      "*Request Body Parameter*: The verification method to use. One of: `sms` or `call`",
      required: true,
      example: "sms"
    )

    available_locales = Verification.locale.values.map { |l| "`#{l}`" }.join(", ")
    parameter(
      "Locale",
      "*Request Body Parameter*: Locale will automatically resolve based on phone number country code of the recipient for SMS and call channel verifications. It will fallback to English if the selected translation is not available. This parameter will override the automatic locale resolution. The following locales are supported: #{available_locales}.",
      required: false,
      example: "de"
    )

    # https://www.twilio.com/docs/verify/api/verification#start-a-verification-with-sms
    example "1. Start a Verification with SMS" do
      explanation <<~HEREDOC
        To verify a user's phone number, start by requesting to send a verification code to their device.
        Phone numbers must be in E.164 format.
      HEREDOC

      verification_service = create_verification_service
      set_twilio_api_authorization_header(verification_service.account)

      perform_enqueued_jobs do
        do_request(
          ServiceSid: verification_service.id,
          To: "+85512334667",
          Channel: "sms"
        )
      end

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/verify/verification")
      expect(json_response.dig("send_code_attempts", 0, "channel")).to eq("sms")
    end

    # https://www.twilio.com/docs/verify/api/verification#start-a-verification-with-voice
    example "2. Start a Verification with Voice" do
      verification_service = create_verification_service
      set_twilio_api_authorization_header(verification_service.account)

      do_request(
        ServiceSid: verification_service.id,
        To: "+85512334667",
        Channel: "call"
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/verify/verification")
      expect(json_response.dig("send_code_attempts", 0, "channel")).to eq("call")
    end

    example "Start a New SMS Verification to a number with a supported locale", document: false do
      verification_service = create_verification_service
      set_twilio_api_authorization_header(verification_service.account)

      do_request(
        ServiceSid: verification_service.id,
        To: "+491716895430",
        Channel: "sms"
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/verify/verification")
    end

    example "Resend a verification", document: false do
      verification_service = create_verification_service
      verification = create(
        :verification,
        status: :pending,
        channel: :sms,
        verification_service:,
        to: "85512334667"
      )
      create(:verification_delivery_attempt, verification:, channel: :sms)

      set_twilio_api_authorization_header(verification_service.account)

      do_request(
        ServiceSid: verification_service.id,
        To: "+85512334667",
        Channel: "call"
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/verify/verification")
      expect(json_response).to include(
        "sid" => verification.id,
        "channel" => "call"
      )
      expect(json_response.dig("send_code_attempts", 0, "channel")).to eq("sms")
      expect(json_response.dig("send_code_attempts", 1, "channel")).to eq("call")
    end

    example "Fail to Start an SMS Verification", document: false do
      verification_service = create(:verification_service)
      create(:sms_gateway, carrier: verification_service.carrier)

      set_twilio_api_authorization_header(verification_service.account)

      do_request(
        ServiceSid: verification_service.id,
        To: "+85512334667",
        Channel: "sms"
      )

      expect(response_status).to eq(422)
      expect(response_body).to match_api_response_schema("twilio_api/api_errors")
      expect(json_response).to eq(
        "message" => "Could not find a valid phone number to send the verification from.",
        "status" => 422,
        "code" => "S60232",
        "more_info" => "https://www.twilio.com/docs/errors/S60232"
      )
    end
  end

  post "https://verify.somleng.org/v2/Services/:ServiceSid/VerificationCheck" do
    parameter(
      "ServiceSid",
      "*Path Parameter*: The SID of the verification Service to create the resource under.",
    )
    parameter(
      "Code",
      "*Request Body Parameter*: The 4-10 character string being verified.",
      required: true,
      example: "123456"
    )
    parameter(
      "To",
      "*Request Body Parameter*: The phone number to verify. Either this parameter or the `verification_sid`` must be specified. Phone numbers must be in E.164 format.",
      required: false,
      example: "+85512334667"
    )
    parameter(
      "VerificationSid",
      "*Request Body Parameter*: A SID that uniquely identifies the Verification. Either this parameter or the `To` phone number must be specified.",
      required: false,
      example: SecureRandom.uuid
    )

    # https://www.twilio.com/docs/verify/api/verification-check#check-a-verification
    example "3. Check a Verification with a Phone Number" do
      explanation <<~HEREDOC
        This API will check whether the user-provided verification code is correct.

        ⚠️ The verification SID is automatically deleted once it's:

        * expired (10 minutes)
        * approved or canceled

        If any of these occur, verification checks will return a `404 Not Found` error.
        If you'd like to double check what happened with a given verification - please use the Dashboard Verify Logs.
      HEREDOC

      account = create(:account)
      verification_service = create(:verification_service, account:, code_length: 4)
      create(
        :verification,
        status: :pending,
        to: "85512334667",
        code: "1234",
        verification_service:
      )

      set_twilio_api_authorization_header(account)

      do_request(
        ServiceSid: verification_service.id,
        To: "+85512334667",
        Code: "1234"
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/verify/verification_check")
      expect(json_response.fetch("status")).to eq("approved")
    end

    example "4. Check a Verification with a SID" do
      account = create(:account)
      verification_service = create(:verification_service, account:, code_length: 4)
      verification = create(
        :verification,
        status: :pending,
        code: "1234",
        verification_service:
      )

      set_twilio_api_authorization_header(account)

      do_request(
        ServiceSid: verification_service.id,
        VerificationSid: verification.id,
        Code: "1234"
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/verify/verification_check")
      expect(json_response.fetch("status")).to eq("approved")
    end

    example "Check an expired Verification", document: false do
      account = create(:account)
      verification_service = create(:verification_service, account:)
      verification = create(
        :verification,
        :expired,
        code: "1234",
        verification_service:
      )

      set_twilio_api_authorization_header(account)

      do_request(
        ServiceSid: verification_service.id,
        VerificationSid: verification.id,
        Code: "1234"
      )

      expect(response_status).to eq(404)
    end

    example "Check a Verification with too many check attempts", document: false do
      account = create(:account)
      verification_service = create(:verification_service, account:)
      verification = create(
        :verification,
        :too_many_check_attempts,
        status: :pending,
        code: "1234",
        verification_service:
      )

      set_twilio_api_authorization_header(account)

      do_request(
        ServiceSid: verification_service.id,
        VerificationSid: verification.id,
        Code: "1234"
      )

      expect(response_status).to eq(422)
      expect(response_body).to match_api_response_schema("twilio_api/api_errors")
      expect(json_response).to eq(
        "message" => "Max check attempts reached",
        "status" => 422,
        "code" => "60202",
        "more_info" => "https://www.twilio.com/docs/errors/60202"
      )
    end
  end

  get "https://verify.somleng.org/v2/Services/:ServiceSid/Verifications/:Sid" do
    parameter(
      "ServiceSid",
      "*Path Parameter*: The SID of the Verification Service to fetch the Verification from.",
    )
    parameter(
      "Sid",
      "*Path Parameter*: The SID of the Verification.",
    )

    # https://www.twilio.com/docs/verify/api/verification#fetch-a-verification
    example "5. Fetch a Verification" do
      account = create(:account)
      verification_service = create(:verification_service, account:)
      verification = create(:verification, verification_service:)

      set_twilio_api_authorization_header(account)

      do_request(
        ServiceSid: verification_service.id,
        Sid: verification.id
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/verify/verification")
    end
  end

  post "https://verify.somleng.org/v2/Services/:ServiceSid/Verifications/:Sid" do
    parameter(
      "ServiceSid",
      "*Path Parameter*: The SID of the Verification Service to update the resource from.",
    )
    parameter(
      "Sid",
      "The SID of the Verification resource to update.",
    )
    parameter(
      "To",
      "The phone number or email to verify. Phone numbers must be in E.164 format.",
      required: true,
      example: "+85512334667"
    )
    parameter(
      "Status",
      "The new status of the resource. Can be: `canceled` or `approved`.",
      required: true,
      example: "approved"
    )

    # https://www.twilio.com/docs/verify/api/verification#update-a-verification-status
    example "6. Update a Verification Status" do
      explanation <<~HEREDOC
        Manually mark the verification as `approved` after your application had validated the verification code or
        mark the verification as `canceled` to start a new verification session with a different code
        before the previous code expires (10 minutes). Only recommended during testing or if you're using custom verification codes.

        For most other use cases, Verify is able to manage the complete lifecycle of a verification with the Verification Check Resource.
      HEREDOC

      account = create(:account)
      verification_service = create(:verification_service, account:)
      verification = create(:verification, status: :pending, verification_service:)

      set_twilio_api_authorization_header(account)

      do_request(
        ServiceSid: verification_service.id,
        Sid: verification.id,
        Status: "approved"
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/verify/verification")
      expect(json_response.fetch("status")).to eq("approved")
    end
  end

  def create_verification_service(attributes = {})
    verification_service = create(:verification_service, attributes)
    phone_number = create(:phone_number, carrier: verification_service.carrier)
    create(:sms_gateway, carrier: verification_service.carrier, default_sender: phone_number.number)
    create(:sip_trunk, carrier: verification_service.carrier, default_sender: phone_number.number)
    verification_service
  end
end
