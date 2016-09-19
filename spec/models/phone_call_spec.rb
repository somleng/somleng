require 'rails_helper'

describe PhoneCall do
  let(:factory) { :phone_call }

  it_behaves_like "twilio_api_resource"
  it_behaves_like "twilio_url_logic"
  it_behaves_like "phone_number_attribute" do
    let(:phone_number_attribute) { :to }
  end

  describe "associations" do
    it { is_expected.to belong_to(:incoming_phone_number) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:from) }

    context "persisted" do
      subject { create(factory) }

      context "#external_id" do
        it { is_expected.to validate_uniqueness_of(:external_id).allow_nil.strict }
      end
    end

    context "for inbound calls" do
      subject { build(factory, :inbound) }
      it { is_expected.to validate_presence_of(:external_id) }
      it { is_expected.to validate_presence_of(:incoming_phone_number) }
    end
  end

  describe "json" do
    let(:json) { JSON.parse(subject.public_send(json_method)) }

    describe "#to_json" do
      let(:json_method) { :to_json }
      subject { create(factory) }
      it { expect(json.keys).to include("to", "from", "status") }
    end

    describe "#to_internal_outbound_call_json" do
      subject { create(factory, :with_optional_attributes) }
      let(:json_method) { :to_internal_outbound_call_json }
      it { expect(json.keys).to match_array(["sid", "account_sid", "account_auth_token", "voice_url", "voice_method", "status_callback_url", "status_callback_method", "from", "to", "routing_instructions"]) }
    end

    describe "#to_internal_inbound_call_json" do
      subject { create(factory, :inbound) }
      let(:json_method) { :to_internal_inbound_call_json }
      it { expect(json.keys).to match_array(["sid", "account_sid", "account_auth_token", "voice_url", "voice_method", "status_callback_url", "status_callback_method", "from", "to"]) }
    end
  end

  describe "#uri" do
    subject { create(factory) }
    it { expect(subject.uri).to eq("/api/2010-04-01/Accounts/#{subject.account_sid}/Calls/#{subject.sid}") }
  end

  describe "#initate_or_cancel!" do
    before do
      subject.initiate_or_cancel!
    end

    context "given there's a external_id" do
      subject { create(factory, :queued, :with_external_id) }
      it { is_expected.to be_initiated }
    end

    context "given there is no external_id" do
      subject { create(factory, :queued) }
      it { is_expected.to be_canceled }
    end
  end

  describe "#initiate_outbound_call!" do
    subject { create(factory, :queued) }
    let(:outbound_call_id) { generate(:external_id) }
    let(:outbound_call_job) { instance_double(Twilreapi::Worker::Job::OutboundCallJob, :perform => outbound_call_id) }

    def assert_call_initiated!
      allow(Twilreapi::Worker::Job::OutboundCallJob).to receive(:new).and_return(outbound_call_job)
      expect(outbound_call_job).to receive(:perform).with(subject.to_internal_outbound_call_json)
      subject.initiate_outbound_call!
      expect(subject.external_id).to eq(outbound_call_id)
      is_expected.to be_initiated
    end

    it { assert_call_initiated! }
  end

  describe "#initiate_inbound_call" do
    let(:phone_number) { generate(:phone_number) }
    let(:external_id) { generate(:external_id) }

    subject { build(factory, :to => phone_number, :external_id => external_id) }

    def setup_scenario
    end

    before do
      setup_scenario
      subject.initiate_inbound_call
    end

    context "given no matching incoming phone number" do
      def assert_errors!
        is_expected.not_to be_persisted
        expect(subject.errors).not_to be_empty
      end

      it { assert_errors! }
    end

    context "given an matching incoming phone number" do
      let(:incoming_phone_number) { create(:incoming_phone_number, :phone_number => phone_number) }

      def setup_scenario
        super
        incoming_phone_number
      end

      def assert_created!
        is_expected.to be_persisted
        expect(subject.voice_url).to eq(incoming_phone_number.voice_url)
        expect(subject.voice_method).to eq(incoming_phone_number.voice_method)
        expect(subject.status_callback_url).to eq(incoming_phone_number.status_callback_url)
        expect(subject.status_callback_method).to eq(incoming_phone_number.status_callback_method)
        expect(subject.external_id).to eq(external_id)
        expect(subject.account).to eq(incoming_phone_number.account)
        expect(subject.incoming_phone_number).to eq(incoming_phone_number)
        is_expected.to be_initiated
      end

      it { assert_created! }
    end
  end

  describe "#enqueue_outbound_call!" do
    include Twilreapi::SpecHelpers::EnvHelpers
    include ActiveJob::TestHelper

    subject { create(factory) }
    let(:enqueued_job) { enqueued_jobs.first }

    before do
      subject.enqueue_outbound_call!
    end

    def assert_enqueued!
      expect(enqueued_job[:args]).to match_array([subject.id])
    end

    it { assert_enqueued! }
  end
end
