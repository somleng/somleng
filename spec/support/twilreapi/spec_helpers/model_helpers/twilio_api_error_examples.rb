shared_examples_for "twilio_api_error" do
  describe "#to_hash" do
    def assert_to_hash!
      expect(subject.to_hash).to eq(asserted_hash)
    end

    it { assert_to_hash! }
  end
end
