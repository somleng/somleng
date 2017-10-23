require 'rails_helper'

describe Account do
  let(:factory) { :account }

  describe "associations" do
    it { is_expected.to have_one(:access_token) }
    it { is_expected.to have_many(:phone_calls) }
    it { is_expected.to have_many(:recordings) }
    it { is_expected.to have_many(:incoming_phone_numbers) }
  end

  describe "defaults" do
    subject { create(factory) }

    describe "#permissions" do
      it { expect(subject.permissions).to be_empty }
    end
  end

  describe "state_machine" do
    def subject_attributes
      {:status => current_status}
    end

    subject { create(factory, subject_attributes) }

    context "state is 'enabled'" do
      let(:current_status) { :enabled }

      def assert_transitions!
        is_expected.to transition_from(:enabled).to(:disabled).on_event(:disable)
      end

      it { assert_transitions! }
    end

    context "state is 'disabled'" do
      let(:current_status) { :disabled }

      def assert_transitions!
        is_expected.to transition_from(:disabled).to(:enabled).on_event(:enable)
      end

      it { assert_transitions! }
    end
  end

  describe "#build_usage_record_collection(params = {})" do
    let(:params) { {} }
    let(:usage_record_collection) { subject.build_usage_record_collection(params) }

    def assert_usage_record!
      expect(usage_record_collection.account).to eq(subject)
    end

    it { assert_usage_record! }
  end
end
