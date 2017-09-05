shared_examples_for "phone_call_event" do
  describe "associations" do
    it { is_expected.to belong_to(:phone_call) }
    it { is_expected.to belong_to(:recording) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:type) }
  end

  describe "factory" do
    subject { create(factory) }
    it { is_expected.to be_valid }
  end

  describe "#to_json" do
    let(:phone_call) { create(:phone_call) }
    let(:recording) { create(:recording, :phone_call => phone_call) }
    let(:json) { JSON.parse(subject.to_json) }

    subject { create(factory, :phone_call => phone_call, :recording => recording) }

    let(:asserted_json_keys) { ["created_at", "id", "params", "updated_at", "phone_call", "recording"] }

    def assert_json!
      expect(json.keys).to match_array(asserted_json_keys)
    end

    it { assert_json! }
  end

  include_examples("event_publisher")
end
