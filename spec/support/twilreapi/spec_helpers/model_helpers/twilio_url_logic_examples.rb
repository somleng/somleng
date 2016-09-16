shared_examples_for "twilio_url_logic" do
  describe "url validations" do
    it { is_expected.to validate_presence_of(:voice_url) }
  end

  describe "method validations" do
    it { is_expected.to validate_inclusion_of(:voice_method).in_array(["POST", "GET"]) }

    context "persisted" do
      subject { create(factory) }

      context "#method" do
        it { is_expected.to validate_presence_of(:voice_method) }
      end
    end
  end

  describe "method defaults" do
    subject { create(factory) }

    def assert_defaults!
      expect(subject.voice_method).to eq("POST")
    end

    it { assert_defaults! }
  end

  describe "method normalization" do
    subject { create(factory, :with_denormalized_voice_method) }
    let(:asserted_normalized_attributes) { attributes_for(factory, :with_normalized_voice_method) }

    def assert_normalization!
      expect(subject.voice_method).to eq(asserted_normalized_attributes[:voice_method])
    end

    it { assert_normalization! }
  end
end
