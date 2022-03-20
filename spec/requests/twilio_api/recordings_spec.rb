require "rails_helper"

RSpec.resource "Phone Calls", document: :twilio_api do
  get "https://api.somleng.org/2010-04-01/Accounts/:account_sid/Calls/:call_sid/Recordings/:sid.json" do
    example "Fetch a recording" do
      recording = create(:recording, :completed)

      do_request(account_sid: recording.account_id, call_sid: recording.phone_call_id, sid: recording.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/recording")
    end
  end
end
