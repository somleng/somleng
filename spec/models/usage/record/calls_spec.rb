require 'rails_helper'

describe Usage::Record::Calls do
  let(:factory) { :calls_usage_record }

  include_examples "usage_record"

  describe ".category" do
    it { expect(described_class.category).to eq("calls") }
  end

  describe ".description" do
    it { expect(described_class.description).to eq("Voice Minutes") }
  end

  describe ".count_unit" do
    it { expect(described_class.count_unit).to eq("calls") }
  end

  describe ".usage_unit" do
    it { expect(described_class.usage_unit).to eq("minutes") }
  end

  describe ".price_unit" do
    it { expect(described_class.price_unit).to eq("usd") }
  end

  describe "#count" do
    subject { build(factory, :account => account) }
    let(:account) { create(:account) }

    before do
      create(:call_data_record, :billable, :account => account)
    end

    def assert_count!
      expect(subject.count).to eq(1)
    end

    it { assert_count! }
  end

  describe "#usage" do
    subject { build(factory, :account => account) }
    let(:account) { create(:account) }

    before do
      create(:call_data_record, :account => account, :bill_sec => 60)
    end

    def assert_usage!
      expect(subject.usage).to eq(1)
    end

    it { assert_usage! }
  end
end
