require "rails_helper"

module UsageRecord
  RSpec.describe Calls do
    it { expect(build_usage_record.description).to eq("Voice Minutes") }
    it { expect(build_usage_record.usage_unit).to eq("minutes") }
    it { expect(build_usage_record.count_unit).to eq("calls") }

    describe "#count" do
      it "returns the record count" do
        filter_params = {
          start_date: Date.new(2018, 1, 2),
          end_date: Date.new(2018, 1, 3)
        }
        account = create(:account)

        _started_before_start_date = create_phone_call_with_cdr(
          :billable,
          account: account,
          start_time: Date.new(2018, 1, 1)
        )
        _started_after_end_date = create_phone_call_with_cdr(
          :billable,
          account: account,
          start_time: Date.new(2018, 1, 4)
        )
        _not_billable = create_phone_call_with_cdr(
          :not_billable,
          account: account,
          start_time: filter_params.fetch(:start_date)
        )
        _different_account = create_phone_call_with_cdr(
          :billable,
          start_time: filter_params.fetch(:start_date)
        )
        create_phone_call_with_cdr(
          :billable,
          account: account,
          start_time: filter_params.fetch(:start_date)
        )
        create_phone_call_with_cdr(
          :billable,
          account: account,
          start_time: filter_params.fetch(:end_date)
        )

        usage_record = build_usage_record(
          account: account, **filter_params
        )

        results = usage_record.count

        expect(results).to eq(2)
      end
    end

    describe "#price" do
      it "returns the price in USD" do
        account = create(:account)
        create_phone_call_with_cdr(:billable, account: account, price: Money.new(50_000, "USD6"))
        create_phone_call_with_cdr(:billable, account: account, price: Money.new(70_000, "USD6"))
        _different_account = create_phone_call_with_cdr(:billable, price: Money.new(70_000, "USD6"))

        usage_record = build_usage_record(account: account)

        expect(usage_record.price).to eq(Money.from_amount(0.12, "USD"))
      end
    end

    describe "#usage" do
      it "returns the bill minutes" do
        account = create(:account)

        create_phone_call_with_cdr(:billable, account: account, bill_sec: 1) # 1 minute
        create_phone_call_with_cdr(:billable, account: account, bill_sec: 1) # 1 minute
        create_phone_call_with_cdr(:billable, account: account, bill_sec: 61) # 2 minutes
        _different_account = create_phone_call_with_cdr(:billable, bill_sec: 61)

        usage_record = build_usage_record(account: account)

        expect(usage_record.usage).to eq(4)
      end
    end

    def build_usage_record(config = {})
      described_class.new("calls", build(:usage_record_collection, config))
    end
  end
end
