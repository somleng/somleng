require "rails_helper"

module UsageRecord
  RSpec.describe CallsInbound do
    it { expect(build_usage_record.description).to eq("Inbound Voice Minutes") }

    describe "#count" do
      it "returns the record count" do
        account = create(:account)

        create_phone_call_with_cdr(:billable, :inbound, account: account)
        create_phone_call_with_cdr(:billable, :outbound, account: account)
        _different_account = create_phone_call_with_cdr(:billable, :inbound)

        usage_record = build_usage_record(account: account)

        expect(usage_record.count).to eq(1)
      end
    end

    def build_usage_record(config = {})
      described_class.new("calls-inbound", build(:usage_record_collection, config))
    end
  end
end
