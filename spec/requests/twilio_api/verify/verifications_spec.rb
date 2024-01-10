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

    parameter(
      "CustomFriendlyName",
      "A custom user defined friendly name that overwrites the existing one in the verification message",
      required: false,
      example: "My friendly name"
    )

    example "Start New Verification" do
      account = create(:account)
      verification_service = create(:verification_service, account:)

      set_twilio_api_authorization_header(account)

      do_request(
        service_sid: verification_service.id,
        To: "+85512334667",
        Channel: "sms"
      )

      expect(response_status).to eq(201)
      expect(response_body).to match_api_response_schema("twilio_api/verify/verification")
    end
  end

  # https://www.twilio.com/docs/verify/api/verification#update-a-verification-status

  post "https://verify.somleng.org/v2/Services/:service_sid/Verifications/:sid" do
    explanation <<~HEREDOC
      Mark the verification as `approved` after your application had validated the verification code or
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
