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
    it { is_expected.to validate_presence_of(:start_time) }
    it { is_expected.to validate_presence_of(:end_time) }
  end

  describe "price" do
    it { is_expected.to monetize(:price) }
  end

  describe "queries" do
    describe ".bill_minutes" do
      before do
        create(:call_data_record, :bill_sec => 60)
        create(:call_data_record, :bill_sec => 61)
        create(:call_data_record, :bill_sec => 0)
        create(:call_data_record, :bill_sec => 1)
      end

      it { expect(described_class.bill_minutes).to eq(4) }
    end

    describe ".total_price_in_usd" do
      before do
        create(:call_data_record, :price => Money.new(8750, "USD6"))
        create(:call_data_record, :price => Money.new(31000, "USD6"))
      end

      it { expect(described_class.total_price_in_usd).to eq(Money.new(4, "USD")) }
    end

    describe ".billable" do
      let(:billable_cdr) { create(:call_data_record, :billable) }

      before do
        billable_cdr
        create(:call_data_record, :not_billable)
      end

      it { expect(described_class.billable).to match_array([billable_cdr]) }
    end

    describe ".between_dates(start_date, end_date)" do
      let(:start_time) { Time.utc("2015", "9", "30", "23", "33", "46") }
      let(:cdr) { create(:call_data_record, :start_time => start_time) }

      before do
        cdr
      end

      def assert_between_dates!
        expect(
          described_class.between_dates(
            Date.new(2015, 9, 29), Date.new(2015, 9, 29)
          )
        ).to match_array([])

        expect(
          described_class.between_dates(
            Date.new(2015, 9, 30), Date.new(2015, 9, 30)
          )
        ).to match_array([cdr])

        expect(
          described_class.between_dates(
            "2015-09-30", "2015-09-30"
          )
        ).to match_array([cdr])

        expect(
          described_class.between_dates(
            Date.new(2015, 9, 30), nil
          )
        ).to match_array([cdr])

        expect(
          described_class.between_dates(
            nil, Date.new(2015, 9, 30)
          )
        ).to match_array([cdr])

        expect(
          described_class.between_dates(
            nil, nil
          )
        ).to match_array([cdr])
      end

      it { assert_between_dates! }
    end

    describe ".outbound" do
      let(:outbound_cdr) { create(:call_data_record, :outbound) }

      before do
        outbound_cdr
        create(:call_data_record, :inbound)
      end

      it { expect(described_class.outbound).to match_array([outbound_cdr]) }
    end

    describe ".inbound" do
      let(:inbound_cdr) { create(:call_data_record, :inbound) }

      before do
        inbound_cdr
        create(:call_data_record, :outbound)
      end

      it { expect(described_class.inbound).to match_array([inbound_cdr]) }
    end
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
        expect(subject.start_time).to eq(Time.at(freeswitch_cdr.start_epoch.to_i))
        expect(subject.end_time).to eq(Time.at(freeswitch_cdr.end_epoch.to_i))
        expect(subject.answer_time).to eq(nil)
        expect(subject.sip_term_status).to eq(freeswitch_cdr.sip_term_status)
        expect(subject.sip_invite_failure_status).to eq(freeswitch_cdr.sip_invite_failure_status)
        expect(subject.sip_invite_failure_phrase).to eq(freeswitch_cdr.sip_invite_failure_phrase)
        expect(subject.price).to eq(0)
      end

      it { assert_cdr_processed! }
    end
  end
end
