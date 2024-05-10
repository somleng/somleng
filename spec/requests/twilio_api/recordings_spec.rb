require "rails_helper"

RSpec.resource "Recordings", document: :twilio_api do
  get "https://api.somleng.org/2010-04-01/Accounts/:AccountSid/Recordings/:Sid" do
    parameter(
      "AccountSid",
      "*Path Parameter*: The SID of the Account that created the Recording resource to fetch."
    )
    parameter(
      "Sid",
      "*Path Parameter*: The SID of the Recording resource to fetch."
    )

    # https://www.twilio.com/docs/voice/api/recording#wav
    example "1. Fetch a Recording's media file" do
      explanation <<~HEREDOC
        You can fetch a Recording's media file by appending `.wav` or `.mp3` to the Recording Resource's URI.

        It's only possible to fetch a Recording's media file when the Recording's status is `completed`.

        If the media associated with a Recording Resource is not available, the request returns `404 Not Found`.

        Without an extension, or with a `.wav`, a binary WAV audio file is returned with mime-type `audio/x-wav`.
      HEREDOC

      recording = create(:recording, :completed)

      do_request(AccountSid: recording.account_id, Sid: recording.id)

      expect(response_status).to eq(302)
      expect(response_headers["Location"]).to end_with(".wav")
    end

    example "Fetch raw recording", document: false do
      recording = create(:recording, :in_progress, raw_recording_url: "https://raw-recordings.s3.amazonaws.com/folder/recording.wav")

      do_request(AccountSid: recording.account_id, Sid: recording.id)

      expect(response_status).to eq(302)
      expect(response_headers["Location"]).to start_with(
        "https://raw-recordings-bucket.s3.ap-southeast-1.amazonaws.com/folder/recording.wav"
      )
    end

    example "404 when the file is not ready", document: false do
      recording = create(:recording, :in_progress)

      do_request(AccountSid: recording.account_id, sid: recording.id)

      expect(response_status).to eq(404)
    end
  end

  get "https://api.somleng.org/2010-04-01/Accounts/:AccountSid/Recordings/:Sid.mp3" do
    parameter(
      "AccountSid",
      "*Path Parameter*: The SID of the Account that created the Recording resource to fetch."
    )
    parameter(
      "Sid",
      "*Path Parameter*: The SID of the Recording resource to fetch."
    )

    # https://www.twilio.com/docs/voice/api/recording#mp3
    example "2. Fetch a Recording as mp3" do
      explanation <<~HEREDOC
        You can fetch a Recording's media file as `mp3` by appending `.mp3` to the Recording Resource's URI.
      HEREDOC

      recording = create(:recording, :completed)

      do_request(AccountSid: recording.account_id, Sid: recording.id)

      expect(response_status).to eq(302)
      expect(response_headers["Location"]).to end_with(".mp3")
    end

    example "Fetch raw recording as mp3", document: false do
      recording = create(:recording, :in_progress, raw_recording_url: "https://raw-recordings.s3.amazonaws.com/folder/recording.wav")

      do_request(AccountSid: recording.account_id, Sid: recording.id)

      expect(response_status).to eq(302)
      expect(response_headers["Location"]).to start_with(
        "https://raw-recordings-bucket.s3.ap-southeast-1.amazonaws.com/folder/recording.mp3"
      )
    end
  end

  get "https://api.somleng.org/2010-04-01/Accounts/:AccountSid/Recordings/:Sid.json" do
    parameter(
      "AccountSid",
      "*Path Parameter*: The SID of the Account that created the Recording resource to fetch."
    )
    parameter(
      "Sid",
      "*Path Parameter*: The SID of the Recording resource to fetch."
    )

    # https://www.twilio.com/docs/voice/api/recording#fetch-recording-resources-metadata
    example "3. Fetch a Recording's metadata" do
      explanation <<~HEREDOC
        A Recording's metadata can be returned in JSON format. Append .json to the Recording Resource's URI.
      HEREDOC

      recording = create(:recording)

      do_request(AccountSid: recording.account_id, Sid: recording.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_schema("twilio_api/recording")
    end
  end

  get "https://api.somleng.org/2010-04-01/Accounts/:AccountSid/Calls/:CallSid/Recordings" do
    parameter(
      "AccountSid",
      "*Path Parameter*: The SID of the Account that created the Recording resource to read."
    )
    parameter(
      "CallSid",
      "*Path Parameter*: The Call SID of the Recording resources to read."
    )

    # https://www.twilio.com/docs/voice/api/recording#read-multiple-recording-resources
    example "4. Get all recordings for a given call" do
      phone_call = create(:phone_call)
      recording = create(:recording, :completed, phone_call:)
      _other_recording = create(:recording)

      set_twilio_api_authorization_header(phone_call.account)
      do_request(AccountSid: phone_call.account_id, CallSid: phone_call.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_collection_schema("twilio_api/recording")
      expect(json_response.fetch("recordings").count).to eq(1)
      expect(json_response.dig("recordings", 0, "sid")).to eq(recording.id)
    end
  end

  get "https://api.somleng.org/2010-04-01/Accounts/:AccountSid/Recordings" do
    parameter(
      "AccountSid",
      "*Path Parameter*: The SID of the Account that created the Recording resource to read."
    )

    # https://www.twilio.com/docs/voice/api/recording#read-multiple-recording-resources
    example "5. List recordings by account" do
      account = create(:account)
      recordings = create_list(:recording, 2, account:)
      _other_recording = create(:recording)

      set_twilio_api_authorization_header(account)
      do_request(AccountSid: account.id)

      expect(response_status).to eq(200)
      expect(response_body).to match_api_response_collection_schema("twilio_api/recording")
      expect(json_response.fetch("recordings").pluck("sid")).to match_array(recordings.map(&:id))
    end
  end
end
