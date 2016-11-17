require 'rails_helper'

describe Account do
  let(:factory) { :account }

  describe "associations" do
    it { is_expected.to have_one(:access_token) }
    it { is_expected.to have_many(:phone_calls) }
    it { is_expected.to have_many(:incoming_phone_numbers) }
  end

  describe "defaults" do
    subject { create(factory) }

    describe "#permissions" do
      it { expect(subject.permissions).to be_empty }
    end
  end

  describe "#build_usage_record(params = {})" do
    let(:params) { {} }
    let(:usage_record) { subject.build_usage_record(params) }

    def assert_usage_record!
      expect(usage_record.account).to eq(subject)
    end

    it { assert_usage_record! }
  end
end
