require "rails_helper"

RSpec.resource "Phone Calls", document: :twilio_api do
  get "https://api.somleng.org/2010-04-01/Accounts/:account_sid/Calls/:call_sid/Recordings" do
    example "List recordings" do
      phone_call = create(:phone_call)
      recording = create(:recording, :completed, phone_call: phone_call)
      _other_recording = create(:recording)

      set_twilio_api_authorization_header(phone_call.account)
      do_request(account_sid: phone_call.account_id, call_sid: phone_call.id, foobar: true)

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_collection_schema("twilio_api/recording")
      expect(json_response.fetch("recordings").count).to eq(1)
      expect(json_response.dig("recordings", 0, "sid")).to eq(recording.id)
    end
  end

  get "https://api.somleng.org/2010-04-01/Accounts/:account_sid/Calls/:call_sid/Recordings/:sid.json" do
    example "Fetch a recording" do
      recording = create(:recording, :completed)

      do_request(account_sid: recording.account_id, call_sid: recording.phone_call_id, sid: recording.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/recording")
    end
  end
end
