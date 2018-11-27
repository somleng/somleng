require "rails_helper"

describe IncomingPhoneNumber do
  let(:factory) { :incoming_phone_number }

  it_behaves_like "twilio_url_logic"
  it_behaves_like "phone_number_attribute", validate_format: false do
    let(:phone_number_attribute) { :phone_number }
  end

  describe "associations" do
    it { is_expected.to belong_to(:account) }
    it { is_expected.to have_many(:phone_calls) }
  end

  describe "validations" do
    context "persisted" do
      subject { create(factory) }

      context "#phone_number" do
        it { is_expected.to validate_uniqueness_of(:phone_number).strict.case_insensitive }
      end
    end
  end

  describe "#to_json" do
    subject { create(factory) }

    let(:json) { JSON.parse(subject.to_json) }

    def assert_json!
      expect(json.keys).to include("phone_number")
      expect(json.keys).to include("twilio_request_phone_number")
    end

    it { assert_json! }
  end
end
