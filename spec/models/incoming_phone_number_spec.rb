require 'rails_helper'

describe IncomingPhoneNumber do
  let(:factory) { :incoming_phone_number }

  it_behaves_like "twilio_api_resource"
  it_behaves_like "twilio_url_logic"
  it_behaves_like "phone_number_attribute" do
    let(:phone_number_attribute) { :phone_number }
  end

  describe "#to_json" do
    subject { create(factory) }
    let(:json) { JSON.parse(subject.to_json) }
    it { expect(json.keys).to include("phone_number") }
  end

  describe "validations" do
    context "persisted" do
      subject { create(factory) }

      context "#phone_number" do
        it { is_expected.to validate_uniqueness_of(:phone_number).strict.case_insensitive }
      end
    end
  end
end
