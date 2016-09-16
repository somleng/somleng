require 'rails_helper'

describe PhoneCall do
  let(:factory) { :phone_call }

  it_behaves_like "twilio_api_resource"
  it_behaves_like "twilio_url_logic"
  it_behaves_like "phone_number_attribute" do
    let(:phone_number_attribute) { :to }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:from) }

    context "persisted" do
      subject { create(factory) }

      context "#somleng_call_id" do
        it { is_expected.to validate_uniqueness_of(:somleng_call_id).allow_nil.strict }
      end
    end
  end

  describe "#to_json" do
    subject { create(factory) }
    let(:json) { JSON.parse(subject.to_json) }
    it { expect(json.keys).to include("to", "from", "status") }
  end

  describe "#to_somleng_json" do
    subject { create(factory, :with_optional_attributes) }
    let(:json) { JSON.parse(subject.to_somleng_json) }
    it { expect(json.keys).to match_array(["sid", "account_sid", "account_auth_token", "voice_url", "voice_method", "status_callback_url", "status_callback_method", "from", "to", "routing_instructions"]) }
  end

  describe "#uri" do
    subject { create(factory) }
    it { expect(subject.uri).to eq("/api/2010-04-01/Accounts/#{subject.account_sid}/Calls/#{subject.sid}") }
  end

  describe "#initate_or_cancel!" do
    before do
      subject.initiate_or_cancel!
    end

    context "given there's a somleng_call_id" do
      subject { create(factory, :queued, :with_somleng_call_id) }
      it { is_expected.to be_initiated }
    end

    context "given there is no somleng_call_id" do
      subject { create(factory, :queued) }
      it { is_expected.to be_canceled }
    end
  end

  describe "#initiate_outbound_call!" do
    subject { create(factory, :queued) }
    let(:outbound_call_id) { generate(:somleng_call_id) }
    let(:outbound_call_job) { instance_double(Twilreapi::Worker::Job::OutboundCallJob, :perform => outbound_call_id) }

    def assert_call_initiated!
      allow(Twilreapi::Worker::Job::OutboundCallJob).to receive(:new).and_return(outbound_call_job)
      expect(outbound_call_job).to receive(:perform).with(subject.to_somleng_json)
      subject.initiate_outbound_call!
      expect(subject.somleng_call_id).to eq(outbound_call_id)
      is_expected.to be_initiated
    end

    it { assert_call_initiated! }
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
