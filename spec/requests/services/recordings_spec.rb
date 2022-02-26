require "rails_helper"

RSpec.describe "Services" do
  describe "POST /services/recordings" do
    it "creates a recording" do
      phone_call = create(:phone_call)

      post(
        services_recordings_path(),
        params: { phone_call_id: phone_call.id, external_id: "recording-id" },
        headers: build_authorization_headers("services", "password")
      )

      expect(response.code).to eq("201")
      expect(response.body).to match_api_response_schema("services/recording")
    end
  end
end
