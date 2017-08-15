shared_examples_for "twilio_url_logic" do
  describe "url validations" do
    it { is_expected.to validate_presence_of(:voice_url) }

    [:voice_url, :status_callback_url].each do |url_attribute|
      it { is_expected.to allow_value("http://my-project.com").for(url_attribute) }
      it { is_expected.to allow_value("https://my-project.com").for(url_attribute) }
      it { is_expected.not_to allow_value("ftp://my-project.com").for(url_attribute) }
      it { is_expected.not_to allow_value("ftp://my-project.com").for(url_attribute) }
      it { is_expected.not_to allow_value("http://localhost").for(url_attribute) }
    end
  end

  describe "method validations" do
    [:voice_method, :status_callback_method].each do |url_attribute|
      it { is_expected.to validate_inclusion_of(url_attribute).in_array(["POST", "GET"]) }
    end

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
      expect(subject.status_callback_method).to eq(nil)
    end

    it { assert_defaults! }
  end

  describe "method normalization" do
    let(:denormalized_http_method) { "post" }

    subject {
      create(
        factory,
        :voice_method => denormalized_http_method,
        :status_callback_method => denormalized_http_method
      )
    }

    def assert_normalization!
      expect(subject.voice_method).to eq("POST")
      expect(subject.status_callback_method).to eq("POST")
    end

    it { assert_normalization! }
  end
end
