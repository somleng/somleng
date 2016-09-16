shared_examples_for "twilio_json" do
  describe "#to_json" do
    subject { create(factory) }
    let(:json) { JSON.parse(subject.to_json) }
    it { expect(json.keys).to include("sid", "date_created", "date_updated", "account_sid", "uri") }
  end
end
