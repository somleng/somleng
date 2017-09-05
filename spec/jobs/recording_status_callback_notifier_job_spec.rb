require 'rails_helper'

describe RecordingStatusCallbackNotifierJob do
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

  describe "#perform(recording_id)" do
    let(:phone_call) { create(:phone_call, :from_account_with_access_token) }

    let(:recording) {
      create(
        :recording,
        :with_status_callback_url,
        recording_factory_attributes
      )
    }

    def recording_factory_attributes
      {
        :phone_call => phone_call,
        :duration => 5000
      }
    end

    let(:asserted_request_method) { :post }
    let(:asserted_request_url) { recording.status_callback_url }
    let(:http_request_params) { WebMock.request_params(http_request) }
    let(:http_request) { WebMock.requests.last }

    def setup_scenario
      stub_request(asserted_request_method, asserted_request_url)
      subject.perform(recording.id)
    end

    before do
      setup_scenario
    end

    def assert_perform!
      expect(WebMock).to have_requested(
        asserted_request_method, asserted_request_url
      )
      expect(http_request_params["AccountSid"]).to eq(recording.account_sid)
      expect(http_request_params["CallSid"]).to eq(recording.call_sid)
      expect(http_request_params["RecordingSid"]).to eq(recording.sid)
      expect(http_request_params["RecordingUrl"]).to eq(recording.url)
      expect(http_request_params["RecordingStatus"]).to eq(recording.twilio_status)
      expect(http_request_params["RecordingDuration"]).to eq(recording.duration_seconds.to_s)
      expect(http_request_params["RecordingChannels"]).to eq(recording.channels.to_s)
      expect(http_request_params["RecordingSource"]).to eq(recording.source)
    end

    context "by default" do
      it { assert_perform! }
    end

    context "recording#status_callback_method => 'GET'" do
      def recording_factory_attributes
        super.merge(:status_callback_method => "GET")
      end

      let(:asserted_request_method) { :get }
      it { assert_perform! }
    end

    context "recording#status_callback_method => 'HEAD'" do
      def recording_factory_attributes
        super.merge(:status_callback_method => "HEAD")
      end

      let(:asserted_request_method) { :post }
      it { assert_perform! }
    end

    context "recording#status_callback_url is not valid" do
      def recording_factory_attributes
        super.merge(:status_callback_url => "http://localhost:3000")
      end

      def assert_perform!
        expect(WebMock).not_to have_requested(
          asserted_request_method, asserted_request_url
        )
      end

      it { assert_perform! }
    end
  end
end
