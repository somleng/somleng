require "rails_helper"

RSpec.describe ProcessRecording do
  it "attaches a raw recording file to the recording" do
    phone_call = create(
      :phone_call,
      recording_status_callback_url: "https://example.com/recording-callback",
      recording_status_callback_method: "POST"
    )
    recording = create(
      :recording,
      :in_progress,
      duration: 15,
      phone_call: phone_call,
      raw_recording_url: "https://raw-recordings.s3.amazonaws.com/recording.wav"
    )
    s3_client_stub =  Aws::S3::Client.new(
      stub_responses: {
        get_object: ->(_context) { File.open(file_fixture("recording.wav")) }
      }
    )
    stub_request(:post, phone_call.recording_status_callback_url)

    perform_enqueued_jobs do
      ProcessRecording.call(recording, s3_client: s3_client_stub)
    end

    expect(recording.completed?).to eq(true)
    expect(recording.file.attached?).to eq(true)
    expect(WebMock).to have_requested(:post, phone_call.recording_status_callback_url).with { |request|
      payload = Rack::Utils.parse_nested_query(request.body)

      expect(payload).to include(
        "RecordingUrl" => be_present,
        "RecordingDuration" => "15"
      )
    }
  end
end
