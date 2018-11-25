require "rails_helper"

RSpec.describe UsageRecordCollection do

  describe "#usage_records" do
    it "returns all usage_records by default" do
      usage_record_collection = build_usage_record_collection

      result = usage_record_collection.usage_records

      expect(
        result.map(&:class)
      ).to match_array(
        [
          UsageRecord::Calls,
          UsageRecord::CallsInbound,
          UsageRecord::CallsOutbound
        ]
      )
    end

    it "returns the Category if specified" do
      usage_record_collection = build_usage_record_collection(Category: "calls-inbound")

      result = usage_record_collection.usage_records

      expect(result.map(&:class)).to match_array([UsageRecord::CallsInbound])
    end
  end

  describe "#start_date" do
    it "returns 27/3/2010 by default" do
      usage_record_collection = build_usage_record_collection

      result = usage_record_collection.start_date

      expect(result).to eq(Date.new(2010, 3, 27))
    end

    it "retuns StartDate if specified" do
      date = Date.new(2015, 9, 30)
      usage_record_collection = build_usage_record_collection(StartDate: date)

      result = usage_record_collection.start_date

      expect(result).to eq(date)
    end
  end

  describe "#end_date" do
    it "returns the current date by default" do
      usage_record_collection = build_usage_record_collection

      result = usage_record_collection.end_date

      expect(result).to eq(Date.today)
    end

    it "returns EndDate if specified" do
      date = Date.new(2015, 9, 30)
      usage_record_collection = build_usage_record_collection(EndDate: date)

      result = usage_record_collection.end_date

      expect(result).to eq(date)
    end
  end

  def build_usage_record_collection(filter_params = {})
    account = build_stubbed(:account)
    described_class.new(account, filter_params)
  end
end
