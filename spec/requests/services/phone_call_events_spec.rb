require "rails_helper"

RSpec.describe "Services" do
  describe "POST /services/phone_call_events" do
    it "creates a phone call event" do
      phone_call = create(:phone_call, :initiated)

      post(
        services_phone_call_events_path,
        params: {
          phone_call: phone_call.external_id,
          type: "ringing",
          variables: {
            "sip_term_status" => "200",
            "answer_epoch" => "1585814727"
          }
        },
        headers: build_authorization_headers("services", "password")
      )

      expect(response.code).to eq("201")
      expect(response.body).to match_api_response_schema("services/phone_call_event")
      expect(phone_call.reload.status).to eq("ringing")
    end
  end
end
