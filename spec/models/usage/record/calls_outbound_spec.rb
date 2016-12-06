require 'rails_helper'

describe Usage::Record::CallsOutbound do
  let(:factory) { :calls_outbound_usage_record }
  let(:asserted_category) { "calls-outbound" }
  let(:call_data_record_traits) { [:billable, :outbound] }

  include_examples "calls_usage_record"

  describe ".description" do
    it { expect(described_class.description).to eq("Outbound Voice Minutes") }
  end
end

