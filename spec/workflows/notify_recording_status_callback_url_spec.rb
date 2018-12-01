require "rails_helper"

describe NotifyRecordingStatusCallbackUrl do
  # From: # https://www.twilio.com/docs/api/twiml/record#attributes-recording-status-callback

  # The 'recordingStatusCallback' attribute takes a relative or absolute URL
  # as an argument. If a 'recordingStatusCallback' URL is given,
  # Twilio will make a GET or POST request to the specified URL when the recording
  # is available to access.

  # Request Parameters

  # Twilio will pass the following parameters with its request to the
  # 'recordingStatusCallback' URL:

  # | Parameter         | Description                                           |
  # |                   |                                                       |
  # | AccountSid        | The unique identifier of the Account                  |
  # |                   | responsible for this recording.                       |
  # |                   |                                                       |
  # | CallSid           | A unique identifier for the call associated           |
  # |                   | with the recording.                                   |
  # |                   |                                                       |
  # |                   | To get a final accurate recording duration after any  |
  # |                   | trimming of silence, use recordingStatusCallback.     |
  # |                   |                                                       |
  # | RecordingSid      | he URL of the recorded audio.                         |
  # |                   |                                                       |
  # | RecordingUrl      | The unique identifier for the recording.              |
  # |                   |                                                       |
  # | RecordingStatus   | The status of the recording.                          |
  # |                   | Possible values are: completed.                       |
  # |                   |                                                       |
  # | RecordingDuration | The length of the recording, in seconds.              |
  # |                   |                                                       |
  # | RecordingChannels | The number of channels in the final recording         |
  # |                   | file as an integer.                                   |
  # |                   | Only 1 channel is supported for the <Record> verb.    |
  # |                   |                                                       |
  # | RecordingSource   | The type of call that created this recording.         |
  # |                   | RecordVerb is returned for recordings                 |
  # |                   | initiated via the <Record> verb.                      |

  it "notifies the recording status callback url via HTTP POST by default" do
    recording = create(:recording, :with_status_callback_url, duration: 5000)
    stub_request(:post, recording.status_callback_url)

    described_class.call(recording)

    expect(WebMock).to have_requested(:post, recording.status_callback_url)
    request_payload = WebMock.request_params(WebMock.requests.last)
    expect(request_payload.fetch("AccountSid")).to eq(recording.account_sid)
    expect(request_payload.fetch("CallSid")).to eq(recording.call_sid)
    expect(request_payload.fetch("RecordingSid")).to eq(recording.sid)
    expect(request_payload.fetch("RecordingUrl")).to eq(recording.url)
    expect(request_payload.fetch("RecordingStatus")).to eq(recording.twilio_status)
    expect(request_payload.fetch("RecordingDuration")).to eq("5")
    expect(request_payload.fetch("RecordingChannels")).to eq(recording.channels.to_s)
    expect(request_payload.fetch("RecordingSource")).to eq(recording.source)
  end

  it "notifies the recording status callback url via HTTP GET if specified" do
    recording = create(:recording, :with_status_callback_url, status_callback_method: "GET")
    stub_request(:get, recording.status_callback_url)

    described_class.call(recording)

    expect(WebMock).to have_requested(:get, recording.status_callback_url)
  end
end
