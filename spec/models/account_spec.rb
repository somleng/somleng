require 'rails_helper'

describe Account do
  let(:factory) { :account }

  describe "associations" do
    it { is_expected.to have_one(:access_token) }
    it { is_expected.to have_many(:phone_calls) }
    it { is_expected.to have_many(:incoming_phone_numbers) }
  end

  context "defaults" do
    subject { create(factory) }

    describe "#permissions" do
      it { expect(subject.permissions).to be_empty }
    end
  end

  describe "#has_permission_to?(action, resource_class)" do
    context ":create_phone_calls" do
      let(:action) { "create" }
      let(:resource_class) { PhoneCall }

      context "for an account with the correct permission" do
        subject { create(factory, :has_permission_to_create_phone_calls) }
        it { is_expected.to have_permission_to(action, resource_class) }
      end

      context "for a normal acccount" do
        it { is_expected.not_to have_permission_to(action, resource_class) }
      end
    end
  end
end
