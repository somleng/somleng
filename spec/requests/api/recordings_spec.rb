require 'rails_helper'

describe "'/api/2010-04-01/Accounts/{AccountSid}/Recordings/{RecordingSid}'" do
  # From: https://www.twilio.com/docs/api/rest/recording

  def setup_scenario
  end

  before do
    setup_scenario
  end

  # From: https://www.twilio.com/docs/api/rest/recording#instance

  # Because these URLs are useful to many external applications,
  # they are public and do not require HTTP Basic Auth to access.
  # This allows you to easily embed the URL in a web application without revealing
  # your Twilio API credentials.
  # The URLs are fairly long and difficult to guess, so the contents of the recordings
  # should be fairly private unless you distribute the URL.
  # For added security, you can enforce HTTP basic auth to access media using your AccountSid and
  # Authentication token via the voice settings page in the console.

  describe "GET '/'" do
    let(:phone_call) { create(:phone_call, :account => account) }

    let(:recording_file) {
      attributes_for(
        :recording,
        :with_wav_file
      )[:file]
    }

    let(:recording) { create(:recording, *recording_traits.keys, recording_attributes) }
    let(:format) { nil }

    def recording_traits
      {}
    end

    def recording_attributes
      {
        :phone_call => phone_call
      }
    end

    def setup_scenario
      do_request(:get, api_twilio_account_recording_path(account_sid, recording.id, :format => format))
    end

    def assert_successful!
      expect(response.code).to eq("200")
    end

    # From: https://www.twilio.com/docs/api/rest/recording#instance-get
    # Returns one of several representations:

    context "Default: WAV" do
      # From: https://www.twilio.com/docs/api/rest/recording#instance-get-wav

      # Without an extension, or with a ".wav", a binary WAV audio file is returned with mime-type
      # "audio/x-wav". For example:

      # GET /2010-04-01/Accounts/ACda6f1.../Recordings/RE557ce644e5ab84fa21cc21112e22c48

      context "file not ready" do
        def assert_not_found!
          expect(response.code).to eq("404")
        end

        it { assert_not_found! }
      end

      context "file ready" do
        def recording_traits
          super.merge(
            :completed => nil,
            :with_wav_file => nil
          )
        end

        def assert_successful!
          super
          expect(response.headers["Content-Disposition"]).to eq("inline; filename=\"#{recording.file_filename}\"")
          expect(response.headers["Content-Type"]).to eq(recording_file.content_type)
          expect(response.body).to eq(recording_file.read)
        end

        it { assert_successful! }
      end
    end

    context "Alternative: JSON" do
      # From: https://www.twilio.com/docs/api/rest/recording#instance-get-xml

      # Appending ".json" to the URI returns a familiar JSON representation. For example:
      # GET /2010-04-01/Accounts/ACda6f1.../Recordings/RE557ce644e5ab84fa21cc21112e22c485.json

      let(:format) { :json }

      def assert_successful!
        super
        expect(response.body).to eq(recording.to_json)
      end

      it { assert_successful! }
    end
  end
end
