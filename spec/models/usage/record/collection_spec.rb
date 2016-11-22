require 'rails_helper'

describe Usage::Record::Collection do
  let(:factory) { :usage_record_collection }

  describe "#initialize" do
    let(:attributes) { attributes_for(factory) }

    let(:params) {
      {
        "account" => attributes[:account],
        "Category" => attributes[:category],
        "StartDate" => attributes[:start_date],
        "EndDate" => attributes[:end_date]
      }
    }

    subject { described_class.new(params) }

    def assert_initialized!
      expect(subject.account).to eq(attributes[:account])
      expect(subject.category).to eq(attributes[:category])
      expect(subject.start_date).to eq(attributes[:start_date])
      expect(subject.end_date).to eq(attributes[:end_date])
    end

    it { assert_initialized! }
  end

  describe "#to_json" do
    subject { create(factory) }
    let(:json) { JSON.parse(subject.to_json) }

    def assert_json!
      expect(json).to have_key("usage_records")
      usage_records = json["usage_records"]
      calls_usage = usage_records[0]
      expect(calls_usage)["category"].to eq("calls")
    end

    it { assert_json! }
  end
end
