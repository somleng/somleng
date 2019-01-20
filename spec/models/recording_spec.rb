require "rails_helper"

RSpec.describe Recording do
  describe "validations" do
    context "#validate_status_callback_url" do
      subject do
        build(
          factory,
          validate_status_callback_url: validate_status_callback_url,
          status_callback_url: "http://localhost:3000"
        )
      end

      def setup_scenario
        subject.valid?
      end

      before do
        setup_scenario
      end

      let(:errors) { subject.errors[:status_callback_url] }

      context "=> true" do
        let(:validate_status_callback_url) { true }

        it { expect(errors).to be_present }
      end

      context "=> false" do
        let(:validate_status_callback_url) { false }

        it { expect(errors).to be_empty }
      end
    end
  end

  describe "state_machine" do
    def setup_scenario
      subject
    end

    before do
      setup_scenario
    end

    describe "#complete" do
      let(:event) { :complete }

      context "can complete" do
        subject { create(factory, :can_complete) }

        it("broadcasts") {
          assert_broadcasted!(:recording_completed) { subject.complete! }
        }
      end

      context "already completed" do
        subject { create(factory, :completed) }

        it("does not broadcast") {
          assert_not_broadcasted!(:recording_completed) { subject.complete! }
        }
      end
    end
  end

  describe "#twiml_instructions" do
    subject { build(factory, factory_attributes) }

    def factory_attributes
      {}
    end

    def assert_result!
      expect(result).to eq(asserted_result)
    end

    describe "#status_callback_url" do
      let(:result) { subject.status_callback_url }
      let(:status_callback_url) { "http://somleng.org/status-callback-url" }
      let(:asserted_result) { status_callback_url }

      def factory_attributes
        super.merge(status_callback_url: status_callback_url)
      end

      it { assert_result! }
    end

    describe "#status_callback_method" do
      let(:result) { subject.status_callback_method }
      let(:status_callback_method) { "POST" }
      let(:asserted_result) { status_callback_method }

      def factory_attributes
        super.merge(status_callback_method: status_callback_method)
      end

      it { assert_result! }
    end
  end

  describe "#twilio_status" do
    asserted_twilio_status_mappings = {
      initiated: "processing",
      waiting_for_file: "processing",
      processing: "processing",
      completed: "completed"
    }

    let(:result) { subject.twilio_status }

    asserted_twilio_status_mappings.each do |recording_trait, asserted_twilio_status|
      context "self.status => '#{recording_trait}'" do
        subject { build(factory, recording_trait) }

        it { expect(result).to eq(asserted_twilio_status) }
      end
    end
  end

  describe "#to_wav" do
    subject { build(factory, :with_wav_file) }

    let(:result) { subject.to_wav }
    let(:filename) { result[0] }
    let(:file) { result[1] }

    def assert_to_wav!
      expect(filename).to eq(subject.file_filename)
      expect(file.read).to eq(subject.file.read)
    end

    it { assert_to_wav! }
  end

  describe "#duration_seconds" do
    subject { build(factory, duration: 6030) }

    it { expect(subject.duration_seconds).to eq(6) }
  end

  describe "#uri" do
    it "returns the path of the recording" do
      recording = create(:recording)
      expect(recording.uri).to match_recording_url(recording)
    end
  end

  describe "#url" do
    # From: https://www.twilio.com/docs/api/twiml/record#attributes-recording-status-callback-parameters
    # RecordingUrl - The URL of the recorded audio.

    it "returns the url of the recording" do
      stub_app_settings(default_url_host: "https://www.example.com")
      recording = create(:recording)
      expect(recording.url).to match_recording_url(recording, host: "https://www.example.com")
    end
  end

  RSpec::Matchers.define :match_recording_url do |recording, options = {}|
    match_unless_raises do |url|
      expect(url).to eq(options[:host].to_s + "/api/2010-04-01/Accounts/#{recording.account_sid}/Recordings/#{recording.sid}")
    end
  end

  describe "#call_sid" do
    subject { build(factory) }

    it { expect(subject.call_sid).to eq(subject.phone_call_id) }
  end

  describe "#price" do
    it { expect(subject.price).to eq(nil) }
  end

  describe "#price_unit" do
    it { expect(subject.price_unit).to eq(nil) }
  end

  describe "#source" do
    it { expect(subject.source).to eq("RecordVerb") }
  end

  describe "#source" do
    it { expect(subject.channels).to eq(1) }
  end

  describe "#to_json" do
    # From: https://www.twilio.com/docs/api/rest/recording#instance-properties

    # | PROPERTY    | DESCRIPTION                                                                  |
    # |             |                                                                              |
    # | Sid         | A 34 character string that uniquely identifies this resource.                |
    # |             |                                                                              |
    # | DateCreated | The date that this resource was created, given in RFC 2822 format.           |
    # |             |                                                                              |
    # | DateUpdated | The date that this resource was last updated, given in RFC 2822 format.      |
    # |             |                                                                              |
    # | AccountSid  | The unique id of the Account responsible for this recording.                 |
    # |             |                                                                              |
    # | CallSid     | A unique identifier for the call associated with the recording.              |
    # |             | This will always refer to the parent leg of a two leg call.                  |
    # |             |                                                                              |
    # | Duration    | The length of the recording, in seconds.                                     |
    # |             | This will always refer to the parent leg of a two leg call.                  |
    # |             |                                                                              |
    # | Price       | The one-time cost of creating this recording. Example: -0.00250              |
    # |             |                                                                              |
    # | PriceUnit   | The currency used in the Price property. Example: USD                        |
    # |             |                                                                              |
    # | ApiVersion  | The version of the API in use during the recording.                          |
    # |             |                                                                              |
    # | Uri         | The URI for this resource, relative to https://api.twilio.com                |
    # |             |                                                                              |
    # | Status      | The status of the recording. Possible values are processing, completed.      |
    # |             |                                                                              |
    # | Source      | The type of call that created this recording.                                |
    # |             | Possible values are RecordVerb, DialVerb, Conference, OutboundAPI, Trunking. |
    # |             |                                                                              |
    # | Channels    | The number of channels in the final recording file as an integer.            |
    # |             | Possible values are 1, 2. Separating a two leg call into                     |
    # |             | two separate channels of the recording file is supported                     |
    # |             | in Dial and Outbound Rest API record options.                                |

    subject { create(factory, duration: 5000) }

    let(:json) { JSON.parse(subject.to_json) }

    def assert_json!
      expect(json.keys).to include("call_sid", "duration", "price", "price_unit", "status", "source", "channels")
      expect(json["status"]).to eq(subject.twilio_status)
      expect(json["duration"]).to eq(subject.duration_seconds)
    end

    it { assert_json! }
  end
end
