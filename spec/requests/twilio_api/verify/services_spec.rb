require "rails_helper"

RSpec.resource "Verification Services", document: :twilio_api do
  # https://www.twilio.com/docs/verify/api/service#list-all-services

  get "https://verify.somleng.org/v2/Services" do
    example "List all Services" do
      account = create(:account)
      verification_service = create(:verification_service, account:)

      set_twilio_api_authorization_header(account)

      do_request

      expect(response_status).to eq(200)
      expect(response_body).to match_verify_api_response_collection_schema("twilio_api/verify/service")
      expect(json_response.fetch("services").pluck("sid")).to contain_exactly(verification_service.id)
    end
  end

  # https://www.twilio.com/docs/verify/api/service#fetch-a-service

  get "https://verify.somleng.org/v2/Services/:sid" do
    example "Fetch a Service" do
      account = create(:account)
      verification_service = create(:verification_service, account:)

      set_twilio_api_authorization_header(account)

      do_request(sid: verification_service.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/verify/service")
    end
  end

  # https://www.twilio.com/docs/verify/api/service#create-a-verification-service

  post "https://verify.somleng.org/v2/Services" do
    parameter(
      "FriendlyName",
      "A descriptive string that you create to describe the verification service. It can be up to 32 characters long.",
      required: true,
      example: "My verification service"
    )

    parameter(
      "CodeLength",
      "The length of the verification code to generate. Must be an integer value between 4 and 10, inclusive.",
      required: false,
      example: "4"
    )

    example "Create a Verification Service" do
      account = create(:account)

      set_twilio_api_authorization_header(account)

      do_request(
        account_sid: account.id,
        "FriendlyName" => "My Verification Service"
      )

      expect(response_status).to eq(201)
      expect(response_body).to match_api_response_schema("twilio_api/verify/service")
    end
  end

  # https://www.twilio.com/docs/verify/api/service#update-a-service

  post "https://verify.somleng.org/v2/Services/:sid" do
    parameter(
      "Sid",
      "The SID of the Service Resource to update.",
      required: true
    )

    parameter(
      "FriendlyName",
      "A descriptive string that you create to describe the verification service. It can be up to 32 characters long.",
      required: true,
      example: "My verification service"
    )

    parameter(
      "CodeLength",
      "The length of the verification code to generate. Must be an integer value between 4 and 10, inclusive.",
      required: false,
      example: "4"
    )

    example "Update a Service" do
      account = create(:account)
      verification_service = create(:verification_service, account:, code_length: 4)

      set_twilio_api_authorization_header(account)
      do_request(
        sid: verification_service.id,
        "FriendlyName" => "Rocket Ride Service",
        "CodeLength" => 6
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/verify/service")
      expect(json_response).to include(
        "friendly_name" => "Rocket Ride Service",
        "code_length" => 6
      )
    end
  end

  # https://www.twilio.com/docs/verify/api/service#delete-a-service

  delete "https://verify.somleng.org/v2/Services/:sid" do
    parameter(
      "Sid",
      "The SID of the Service Resource to delete.",
      required: true
    )

    example "Delete a Service" do
      account = create(:account)
      verification_service = create(:verification_service, account:)

      set_twilio_api_authorization_header(account)
      do_request(
        sid: verification_service.id
      )

      expect(response_status).to eq(204)
    end
  end
end
