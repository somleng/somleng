require 'rails_helper'

describe Usage::Record do
  let(:factory) { :usage_record }

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
end
