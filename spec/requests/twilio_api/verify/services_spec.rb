require "rails_helper"

RSpec.resource "Verification Services", document: :twilio_api do
  post "https://verify.somleng.org/v2/Services" do
    parameter(
      "FriendlyName",
      "*Request Body Parameter*: A descriptive string that you create to describe the verification service. It can be up to 32 characters long.",
      required: true,
      example: "My verification service"
    )

    parameter(
      "CodeLength",
      "*Request Body Parameter*: The length of the verification code to generate. Must be an integer value between 4 and 10, inclusive.",
      required: false,
      example: "4"
    )

    # https://www.twilio.com/docs/verify/api/service#create-a-verification-service
    example "01. Create a Verification Service" do
      explanation <<~HEREDOC
        A Verification Service is the set of common configurations used to create and check verifications. You can create a service with the API or in the Console.
      HEREDOC

      account = create(:account)

      set_twilio_api_authorization_header(account)

      do_request(
        "FriendlyName" => "My Verification Service"
      )

      expect(response_status).to eq(201)
      expect(response_body).to match_api_response_schema("twilio_api/verify/service")
    end
  end

  get "https://verify.somleng.org/v2/Services/:Sid" do
    parameter(
      "Sid",
      "*Path Parameter*: The SID of the Verification Service to fetch."
    )

    # https://www.twilio.com/docs/verify/api/service#fetch-a-service
    example "02. Fetch a Service" do
      account = create(:account)
      verification_service = create(:verification_service, account:)

      set_twilio_api_authorization_header(account)

      do_request(Sid: verification_service.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/verify/service")
    end
  end

  get "https://verify.somleng.org/v2/Services" do
    # https://www.twilio.com/docs/verify/api/service#list-all-services
    example "03. List all Services" do
      account = create(:account)
      verification_service = create(:verification_service, account:)

      set_twilio_api_authorization_header(account)

      do_request

      expect(response_status).to eq(200)
      expect(response_body).to match_verify_api_response_collection_schema("twilio_api/verify/service")
      expect(json_response.fetch("services").pluck("sid")).to contain_exactly(verification_service.id)
    end
  end

  post "https://verify.somleng.org/v2/Services/:sid" do
    parameter(
      "Sid",
      "*Path Parameter*: The SID of the Verification Service to update.",
      required: true
    )

    parameter(
      "FriendlyName",
      "*Request Body Parameter*: A descriptive string that you create to describe the Verification Service. It can be up to 32 characters long.",
      required: true,
      example: "My verification service"
    )

    parameter(
      "*Request Body Parameter*: CodeLength",
      "The length of the verification code to generate. Must be an integer value between 4 and 10, inclusive.",
      required: false,
      example: "4"
    )

    # https://www.twilio.com/docs/verify/api/service#update-a-service
    example "04. Update a Service" do
      explanation <<~HEREDOC
        This example updates the `FriendlyName` and `CodeLength` of a Verification Service.
      HEREDOC

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

  delete "https://verify.somleng.org/v2/Services/:Sid" do
    parameter(
      "Sid",
      "*Path Parameter*: The SID of the Verification Service to delete.",
    )

    # https://www.twilio.com/docs/verify/api/service#delete-a-service
    example "05. Delete a Service" do
      account = create(:account)
      verification_service = create(:verification_service, account:)

      set_twilio_api_authorization_header(account)
      do_request(
        Sid: verification_service.id
      )

      expect(response_status).to eq(204)
    end
  end
end
