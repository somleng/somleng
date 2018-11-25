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

  describe "events" do
    subject { create(factory) }
    context "create" do
      it("should broadcast") {
        assert_broadcasted!(:call_data_record_created) { subject }
      }
    end
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

    describe ".outbound" do
      let(:outbound_cdr) { create(factory, :outbound) }

      before do
        outbound_cdr
        create(factory, :inbound)
      end

      it { expect(described_class.outbound).to match_array([outbound_cdr]) }
    end

    describe ".inbound" do
      let(:inbound_cdr) { create(factory, :inbound) }

      before do
        inbound_cdr
        create(:call_data_record, :outbound)
      end

      it { expect(described_class.inbound).to match_array([inbound_cdr]) }
    end
  end

  describe "#completed_event" do
    subject { build(factory, event_trait) }

    describe "#busy?" do
      let(:event_trait) { :event_busy }
      it { is_expected.to be_busy }
    end

    describe "#answered?" do
      let(:event_trait) { :event_answered }
      it { is_expected.to be_answered }
    end

    describe "#not_answered?" do
      let(:event_trait) { :event_not_answered }
      it { is_expected.to be_not_answered }
    end
  end
end
