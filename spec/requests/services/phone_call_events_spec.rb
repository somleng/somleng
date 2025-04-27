require "rails_helper"

RSpec.describe "Services", :services do
  describe "POST /services/phone_call_events" do
    it "creates a phone call event" do
      phone_call = create(
        :phone_call,
        :answered,
        status_callback_url: "https://somleng-status-callback.free.beeceptor.com"
      )

      perform_enqueued_jobs do
        post(
          api_services_phone_call_events_path,
          params: {
            phone_call: phone_call.external_id,
            type: "answered"
          },
          headers: build_authorization_headers("services", "password")
        )
      end

      expect(response.code).to eq("201")
      expect(phone_call.reload).to have_attributes(
        status: "answered",
      )
    end

    it "handles invalid requests" do
      post(
        api_services_phone_call_events_path,
        headers: build_authorization_headers("services", "password")
      )

      expect(response.code).to eq("422")
      expect(response.body).to match_api_response_schema("services/api_errors")
    end
  end
end
