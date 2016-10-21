shared_examples_for "twilio_json" do
  describe "#to_json" do
    subject { create(factory) }
    let(:json) { JSON.parse(subject.to_json) }

    def assert_json!
      expect(json.keys).not_to include("created_at", "updated_at", "id")
      expect(json.keys).to include("sid", "date_created", "date_updated", "account_sid", "uri", "api_version")
      expect(json["api_version"]).to eq("2010-04-01")
    end

    it { assert_json! }
  end
end
