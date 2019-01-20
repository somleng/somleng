require "rails_helper"

describe CallDataRecord do
  describe "validations" do
    it { is_expected.to validate_presence_of(:file) }
    it { is_expected.to validate_presence_of(:duration_sec) }
    it { is_expected.to validate_numericality_of(:duration_sec).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_presence_of(:bill_sec) }
    it { is_expected.to validate_numericality_of(:bill_sec).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_presence_of(:direction) }
    it { is_expected.to validate_inclusion_of(:direction).in_array(%w[inbound outbound]) }
    it { is_expected.to validate_presence_of(:hangup_cause) }
    it { is_expected.to validate_presence_of(:start_time) }
    it { is_expected.to validate_presence_of(:end_time) }
  end

  describe "price" do
    it { is_expected.to monetize(:price) }
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
