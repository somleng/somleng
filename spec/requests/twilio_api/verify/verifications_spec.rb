require "rails_helper"

RSpec.resource "Verifications", document: :twilio_api do
  # https://www.twilio.com/docs/verify/api/verification#fetch-a-verification

  get "https://verify.somleng.org/v2/Services/:service_sid/Verifications/:sid" do
    example "Fetch a Verification" do
      account = create(:account)
      verification_service = create(:verification_service, account:)
      verification = create(:verification, verification_service:)

      set_twilio_api_authorization_header(account)

      do_request(
        service_sid: verification_service.id,
        sid: verification.id
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/verify/verification")
    end
  end

  # https://www.twilio.com/docs/verify/api/verification#start-new-verification

  post "https://verify.somleng.org/v2/Services/:service_sid/Verifications" do
    parameter(
      "ServiceSid",
      "The SID of the verification Service to create the resource under.",
      required: true
    )

    parameter(
      "To",
      "The phone number or email to verify. Phone numbers must be in E.164 format.",
      required: true,
      example: "+85512334667"
    )

    parameter(
      "Channel",
      "The verification method to use. One of: `sms` or `call`",
      required: true,
      example: "sms"
    )

    example "Start New SMS Verification" do
      account = create(:account)
      verification_service = create(:verification_service, account:)
      create(:phone_number, :assigned_to_account, account:)
      create(:sms_gateway, carrier: account.carrier)

      set_twilio_api_authorization_header(account)

      perform_enqueued_jobs do
        do_request(
          service_sid: verification_service.id,
          To: "+85512334667",
          Channel: "sms"
        )
      end

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/verify/verification")
      expect(json_response.dig("send_code_attempts", 0, "channel")).to eq("sms")
    end

    example "Start New Call Verification" do
      account = create(:account)
      verification_service = create(:verification_service, account:)
      create(:phone_number, :assigned_to_account, account:)
      create(:sip_trunk, carrier: account.carrier)

      set_twilio_api_authorization_header(account)

      do_request(
        service_sid: verification_service.id,
        To: "+85512334667",
        Channel: "call"
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/verify/verification")
      expect(json_response.dig("send_code_attempts", 0, "channel")).to eq("call")
    end

    example "Resend a verification", document: false do
      account = create(:account)
      verification_service = create(:verification_service, account:)
      verification = create(
        :verification,
        status: :pending,
        channel: :sms,
        verification_service:,
        to: "85512334667"
      )
      create(:verification_delivery_attempt, verification:, channel: :sms)
      create(:phone_number, :assigned_to_account, account:)
      create(:sip_trunk, carrier: account.carrier)

      set_twilio_api_authorization_header(account)

      do_request(
        service_sid: verification_service.id,
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
      account = create(:account)
      verification_service = create(:verification_service, account:)
      create(:sms_gateway, carrier: account.carrier)

      set_twilio_api_authorization_header(account)

      do_request(
        service_sid: verification_service.id,
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

  # https://www.twilio.com/docs/verify/api/verification-check#check-a-verification

  post "https://verify.somleng.org/v2/Services/:service_sid/VerificationCheck" do
    explanation <<~HEREDOC
      ⚠️ Somleng deletes the verification SID once it's:

      * expired (10 minutes)
      * approved or canceled

      If any of these occur, verification checks will return a 404 not found error like this.
      If you'd like to double check what happened with a given verification - please use the Dashboard Verify Logs.
    HEREDOC

    parameter(
      "ServiceSid",
      "The SID of the verification Service to create the resource under.",
      required: true
    )

    parameter(
      "Code",
      "The 4-10 character string being verified.",
      required: false,
      example: "1234"
    )

    parameter(
      "To",
      "The phone number or email to verify. Either this parameter or the `verification_sid`` must be specified. Phone numbers must be in E.164 format.",
      required: false,
      example: "+85512334667"
    )

    parameter(
      "VerificationSid",
      "A SID that uniquely identifies the Verification. Either this parameter or the `To` phone number/email must be specified.",
      required: false,
      example: SecureRandom.uuid
    )

    example "Check a Verification with a Phone Number" do
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
        service_sid: verification_service.id,
        To: "+85512334667",
        Code: "1234"
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/verify/verification_check")
      expect(json_response.fetch("status")).to eq("approved")
    end

    example "Check a Verification with a SID" do
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
        service_sid: verification_service.id,
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
        service_sid: verification_service.id,
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
        service_sid: verification_service.id,
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

  # https://www.twilio.com/docs/verify/api/verification#update-a-verification-status

  post "https://verify.somleng.org/v2/Services/:service_sid/Verifications/:sid" do
    explanation <<~HEREDOC
      Manually mark the verification as `approved` after your application had validated the verification code or
      mark the verification as `canceled` to start a new verification session with a different code
      before the previous code expires (10 minutes). Only recommended during testing or if you're using custom verification codes.

      For most other use cases, Verify is able to manage the complete lifecycle of a verification with the Verification Check Resource.
    HEREDOC

    parameter(
      "ServiceSid",
      "The SID of the verification Service to create the resource under.",
      required: true
    )

    parameter(
      "Sid",
      "The SID of the Verification resource to update.",
      required: true
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

    example "Update a Verification Status" do
      account = create(:account)
      verification_service = create(:verification_service, account:)
      verification = create(:verification, status: :pending, verification_service:)

      set_twilio_api_authorization_header(account)

      do_request(
        service_sid: verification_service.id,
        sid: verification.id,
        Status: "approved"
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/verify/verification")
      expect(json_response.fetch("status")).to eq("approved")
    end
  end
end
