require "rails_helper"

resource "TTS Events", document: :carrier_api do
  header("Content-Type", "application/vnd.api+json")

  get "https://api.somleng.org/carrier/v1/tts_events" do
    with_options scope: :filter do
      parameter(
        :account, "Return TTS Events from the provided account SID"
      )
      parameter(
        :phone_call, "Return TTS Events from the provided phone call SID"
      )
      parameter(
        :from_date, "Return TTS events on or after the provided date/time in <a href=\"https://en.wikipedia.org/wiki/ISO_8601\">ISO 8601</a> format."
      )
      parameter(
        :to_date, "Return TTS events on or before the provided date/time in <a href=\"https://en.wikipedia.org/wiki/ISO_8601\">ISO 8601</a> format."
      )
    end

    example "List all TTS events" do
      carrier = create(:carrier)
      account = create(:account, carrier:)
      phone_call = create(:phone_call, account:, carrier:)
      tts_events = [
        create(
          :tts_event,
          phone_call:
        ),
        create(
          :tts_event,
          num_chars: 200,
          phone_call:
        )
      ]
      _other_tts_event = create(:tts_event, account:)

      set_carrier_api_authorization_header(carrier)
      do_request(
        filter: {
          from_date: Date.yesterday.iso8601,
          account: account.id,
          phone_call: phone_call.id
        }
      )

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_collection_schema("carrier_api/tts_event")
      expect(json_response.fetch("data").pluck("id")).to match_array(tts_events.pluck(:id))
    end
  end

  get "https://api.somleng.org/carrier/v1/tts_events/:id" do
    example "Retrieve a TTS Event" do
      tts_event = create(:tts_event)

      set_carrier_api_authorization_header(tts_event.carrier)
      do_request(id: tts_event.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_jsonapi_resource_schema("carrier_api/tts_event")
    end
  end
end
