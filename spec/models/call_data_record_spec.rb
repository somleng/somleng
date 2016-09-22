require 'rails_helper'

describe CallDataRecord do
  let(:factory) { :call_data_record }

  describe "associations" do
    it { is_expected.to belong_to(:phone_call) }
  end

  describe "factory" do
    it { expect(create(factory)).to be_persisted }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:phone_call) }
    it { is_expected.to validate_presence_of(:file) }
    it { is_expected.to validate_presence_of(:duration_sec) }
    it { is_expected.to validate_numericality_of(:duration_sec).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_presence_of(:bill_sec) }
    it { is_expected.to validate_numericality_of(:bill_sec).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_presence_of(:direction) }
    it { is_expected.to validate_inclusion_of(:direction).in_array(["inbound", "outbound"]) }
    it { is_expected.to validate_presence_of(:hangup_cause) }
  end

  describe "#enqueue_process!(cdr)" do
    include ActiveJob::TestHelper

    let(:cdr) { {"some" => "cdr_params"}.to_json }

    subject { described_class.new }
    let(:enqueued_job) { enqueued_jobs.first }

    before do
      subject.enqueue_process!(cdr)
    end

    def assert_enqueued!
      expect(enqueued_job[:args]).to match_array([cdr])
    end

    it { assert_enqueued! }
  end

  describe "#process(cdr)" do
    let(:freeswitch_cdr) { build(:freeswitch_cdr) }
    let(:cdr) { freeswitch_cdr.raw_cdr }
    let(:subject) { described_class.new }

    def setup_scenario
    end

    before do
      setup_scenario
      subject.process(cdr)
    end

    context "phone call not found" do
      def assert_cdr_processed!
        expect(subject).not_to be_persisted
      end

      it { assert_cdr_processed! }
    end

    context "phone call found" do
      let(:phone_call) { create(:phone_call, :external_id => freeswitch_cdr.uuid) }

      def setup_scenario
        phone_call
      end

      def assert_cdr_processed!
        expect(subject).to be_persisted
        expect(subject.phone_call).to eq(phone_call)
        expect(subject.direction).to eq(freeswitch_cdr.direction)
        expect(subject.bill_sec).to eq(freeswitch_cdr.bill_sec.to_i)
        expect(subject.duration_sec).to eq(freeswitch_cdr.duration_sec.to_i)
      end

      it { assert_cdr_processed! }
    end
  end
end
