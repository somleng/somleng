require "rails_helper"

describe "Internal Phone Call Events API" do
  describe "GET /api/internal/phone_calls/:phone_call_external_id/phone_call_events/:id" do
    it "gets a phone call event" do
      phone_call = create(:phone_call, external_id: generate(:external_id))
      phone_call_event = create(:phone_call_event, phone_call: phone_call)

      get(
        api_internal_phone_call_phone_call_event_path(phone_call.external_id, phone_call_event),
        headers: build_internal_api_authorization_headers
      )

      expect(response.code).to eq("200")
      expect(response.body).to match_response_schema(:"api/internal/phone_call_event")
      expect(response.body).to eq(phone_call_event.to_json)
    end
  end

  describe "POST /api/internal/phone_calls/:phone_call_external_id/phone_call_events" do
    it "creates a phone call event" do
      phone_call = create(:phone_call, external_id: generate(:external_id))

      params = {
        type: :recording_started
      }

      post(
        api_internal_phone_call_phone_call_events_path(phone_call.external_id),
        params: params,
        headers: build_internal_api_authorization_headers
      )

      expect(response.code).to eq("201")
      expect(response.body).to match_response_schema(:"api/internal/phone_call_event")
      expect(parsed_response_body.fetch("recording_url")).to be_present
    end
  end
end
