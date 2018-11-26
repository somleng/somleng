require "rails_helper"

module UsageRecord
  RSpec.describe CallsOutbound do
    it { expect(build_usage_record.description).to eq("Outbound Voice Minutes") }

    describe "#count" do
      it "returns the record count" do
        account = create(:account)

        create_phone_call_with_cdr(:billable, :inbound, account: account)
        create_phone_call_with_cdr(:billable, :outbound, account: account)
        _different_account = create_phone_call_with_cdr(:billable, :outbound)

        usage_record = build_usage_record(account: account)

        expect(usage_record.count).to eq(1)
      end
    end

    def build_usage_record(config = {})
      described_class.new("calls-outbound", build(:usage_record_collection, config))
    end
  end
end
