shared_examples_for "usage_record" do
  describe ".category" do
    it { expect(described_class.category).to eq(asserted_category) }
  end

  describe "#account_sid" do
    subject { build(factory) }
    it { expect(subject.account_sid).to be_present }
  end

  describe "#uri" do
    let(:account) { create(:account) }
    let(:start_date) { nil }
    let(:end_date) { nil }

    subject { build(factory, :account => account, :start_date => start_date, :end_date => end_date) }

    let(:url) { subject.uri }
    let(:uri) { URI.parse(url) }
    let(:query) { Rack::Utils.parse_query(uri.query) }

    def assert_uri!
      expect(uri.path).to eq(Rails.application.routes.url_helpers.api_twilio_account_usage_records_path(account))
      expect(query["Category"]).to eq(asserted_category)
    end

    context "with dates" do
      let(:start_date) { Date.new(2015, 9, 30) }
      let(:end_date) { Date.new(2015, 10, 31) }

      def assert_uri!
        super
        expect(query["StartDate"]).to eq("2015-09-30")
        expect(query["EndDate"]).to eq("2015-10-31")
      end

      it { assert_uri! }
    end

    context "without dates" do
      def assert_uri!
        super
        expect(query).not_to have_key("StartDate")
        expect(query).not_to have_key("EndDate")
      end

      it { assert_uri! }
    end
  end

  describe "#start_date" do
    let(:start_date) { Date.new(2015, 9, 30) }
    subject { build(factory, :start_date => start_date) }
    it { expect(subject.start_date.to_s).to eq("2015-09-30") }
  end

  describe "#end_date" do
    let(:end_date) { Date.new(2015, 9, 30) }
    subject { build(factory, :end_date => end_date) }
    it { expect(subject.end_date.to_s).to eq("2015-09-30") }
  end

  describe "#subresource_uris" do
    subject { build(factory) }
    let(:subresource_uris) { subject.subresource_uris }

    def assert_subresource_uris!
      expect(subresource_uris).to eq({})
    end

    it { assert_subresource_uris! }
  end

  describe "#to_json" do
    let(:start_date) { Date.new(2015, 9, 30) }
    let(:end_date) { Date.new(2016, 10, 31) }

    subject { build(factory, :start_date => start_date, :end_date => end_date) }
    let(:json) { subject.to_json }
    let(:parsed_json) { JSON.parse(json) }

    let(:json_keys) do
      [
        "category", "description", "account_sid",
        "start_date", "end_date",
        "count", "count_unit", "usage", "usage_unit",
        "price", "price_unit", "api_version", "uri",
         "subresource_uris"
      ]
    end

    def assert_json!
      # Don't escape html entities in JSON
      # http://stackoverflow.com/questions/27379432/prevent-rails-from-encoding-the-ampersands-in-a-url-when-outputting-json
      expect(json).not_to match(/\\u0026/)
      expect(parsed_json.keys).to match_array(json_keys)
    end

    it { assert_json! }
  end
end
