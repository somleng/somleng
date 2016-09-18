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
end
