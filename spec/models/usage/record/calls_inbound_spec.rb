require 'rails_helper'

describe Usage::Record::CallsInbound do
  let(:factory) { :calls_inbound_usage_record }
  let(:asserted_category) { "calls-inbound" }
  let(:call_data_record_traits) { [:billable, :inbound] }

  include_examples "calls_usage_record"

  describe ".description" do
    it { expect(described_class.description).to eq("Inbound Voice Minutes") }
  end
end

