require "rails_helper"

RSpec.describe ProcessRecording do
  it "attaches a raw recording file to the recording" do
    recording = create(
      :recording,
      :in_progress,
      duration: 15,
      status_callback_url: "https://example.com/recording-callback",
      status_callback_method: "POST",
      raw_recording_url: "https://raw-recordings.s3.amazonaws.com/recording.wav"
    )
    s3_client_stub = build_stubbed_s3_client
    stub_request(:post, recording.status_callback_url)

    perform_enqueued_jobs do
      ProcessRecording.call(recording, s3_client: s3_client_stub)
    end

    expect(recording.completed?).to eq(true)
    expect(recording.file.attached?).to eq(true)
    expect(WebMock).to have_requested(:post, recording.status_callback_url).with { |request|
      payload = Rack::Utils.parse_nested_query(request.body)

      expect(payload).to include(
        "RecordingUrl" => Rails.application.routes.url_helpers.twilio_api_account_phone_call_recording_url(
          recording.account,
          recording.phone_call,
          recording
        ),
        "RecordingDuration" => "15"
      )
    }
  end

  it "doesn't notify the status callback" do
    recording = create(
      :recording,
      :in_progress,
      duration: 15,
      raw_recording_url: "https://raw-recordings.s3.amazonaws.com/recording.wav"
    )

    perform_enqueued_jobs do
      ProcessRecording.call(recording, s3_client: build_stubbed_s3_client)
    end

    expect(recording.completed?).to eq(true)
  end

  def build_stubbed_s3_client
    Aws::S3::Client.new(
      stub_responses: {
        get_object: ->(_context) { File.open(file_fixture("recording.wav")) }
      }
    )
  end
end
