require "rails_helper"

RSpec.resource "Phone Calls", document: :twilio_api do
  get "https://api.somleng.org/2010-04-01/Accounts/:account_sid/Calls/:call_sid/Recordings" do
    example "List recordings for a given phone call" do
      phone_call = create(:phone_call)
      recording = create(:recording, :completed, phone_call: phone_call)
      _other_recording = create(:recording)

      set_twilio_api_authorization_header(phone_call.account)
      do_request(account_sid: phone_call.account_id, call_sid: phone_call.id)

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

  get "https://api.somleng.org/2010-04-01/Accounts/:account_sid/Recordings" do
    example "List recordings for a given account" do
      account = create(:account)
      recordings = create_list(:recording, 2, account: account)
      _other_recording = create(:recording)

      set_twilio_api_authorization_header(account)
      do_request(account_sid: account.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_collection_schema("twilio_api/recording")
      expect(json_response.fetch("recordings").pluck("sid")).to match_array(recordings.map(&:id))
    end
  end

  get "https://api.somleng.org/2010-04-01/Accounts/:account_sid/Recordings/:sid" do
    example "Fetch a recording" do
      recording = create(:recording, :completed)

      do_request(account_sid: recording.account_id, sid: recording.id)

      expect(response_status).to eq(302)
      expect(response_headers["Location"]).to end_with(".wav")
    end

    example "404 when the file is not ready", document: false do
      recording = create(:recording, :in_progress)

      do_request(account_sid: recording.account_id, sid: recording.id)

      expect(response_status).to eq(404)
    end
  end

  get "https://api.somleng.org/2010-04-01/Accounts/:account_sid/Recordings/:sid.json" do
    example "Fetch a recording resource" do
      recording = create(:recording)

      do_request(account_sid: recording.account_id, sid: recording.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/recording")
    end
  end
end
