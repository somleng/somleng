require 'rails_helper'

describe Usage::Record::Calls do
  let(:factory) { :calls_usage_record }
  let(:asserted_category) { "calls" }
  let(:call_data_record_traits) { [:billable] }

  include_examples "calls_usage_record"

  describe ".description" do
    it { expect(described_class.description).to eq("Voice Minutes") }
  end
end
