require "rails_helper"

RSpec.describe "Services", :services do
  describe "POST /services/tts_events" do
    it "creates a TTS event" do
      phone_call = create(
        :phone_call,
        :answered
      )

      post(
        api_services_tts_events_path,
        params: {
          phone_call: phone_call.id,
          tts_voice: "Basic.Kal",
          num_chars: 10
        },
        headers: build_authorization_headers("services", "password")
      )

      expect(response).to have_http_status(:created)
      expect(TTSEvent.last).to have_attributes(
        num_chars: 10,
        phone_call:,
        account: phone_call.account,
        carrier: phone_call.carrier,
        tts_provider: "Basic",
        tts_engine: "Standard",
        tts_voice: have_attributes(
          "identifier" => "Basic.Kal"
        )
      )
    end
  end
end
