require 'rails_helper'

describe Usage::Record::Collection do
  let(:factory) { :usage_record_collection }

  describe "#initialize" do
    let(:attributes) { attributes_for(factory) }

    let(:params) {
      {
        "account" => attributes[:account],
        "Category" => attributes[:category],
        "StartDate" => attributes[:start_date],
        "EndDate" => attributes[:end_date]
      }
    }

    subject { described_class.new(params) }

    def assert_initialized!
      expect(subject.account).to eq(attributes[:account])
      expect(subject.category).to eq(attributes[:category])
      expect(subject.start_date).to eq(attributes[:start_date])
      expect(subject.end_date).to eq(attributes[:end_date])
    end

    it { assert_initialized!   }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:account) }
    it { is_expected.to validate_inclusion_of(:category).in_array(["calls", "calls-inbound"]) }
    it { is_expected.to allow_value("2016-09-30").for(:start_date) }
    it { is_expected.not_to allow_value("2016-09-31").for(:start_date) }
    it { is_expected.not_to allow_value("foobarbz").for(:start_date) }
    it { is_expected.to allow_value("2016-09-30").for(:end_date) }
    it { is_expected.not_to allow_value("2016-09-31").for(:end_date) }
    it { is_expected.not_to allow_value("foobarbz").for(:end_date) }

    describe "end_date" do
      let(:start_date) { Date.new(2015, 9, 30) }
      subject { build(factory, :start_date => start_date) }

      it { is_expected.to allow_value("2016-09-30").for(:end_date) }
      it { is_expected.not_to allow_value("2015-09-29").for(:end_date) }
    end
  end

  describe "urls" do
    let(:account) { create(:account) }
    let(:start_date) { Date.new(2015, 9, 30) }
    let(:end_date) { Date.new(2015, 10, 31) }
    subject { build(factory, :account => account, :start_date => start_date, :end_date => end_date, :category => "calls") }

    let(:uri) { URI.parse(url) }
    let(:query) { Rack::Utils.parse_query(uri.query) }

    def assert_uri!
      expect(uri.path).to eq(Rails.application.routes.url_helpers.api_twilio_account_usage_records_path(account))
      expect(query["StartDate"]).to eq("2015-09-30")
      expect(query["EndDate"]).to eq("2015-10-31")
      expect(query["Category"]).to eq("calls")
    end

    describe "#uri" do
      let(:url) { subject.uri }
      it { assert_uri! }
    end

    describe "#first_page_uri" do
      let(:url) { subject.first_page_uri }
      it { assert_uri! }
    end

    describe "#previous_page_uri" do
      it { expect(subject.previous_page_uri).to eq(nil) }
    end

    describe "#next_page_uri" do
      it { expect(subject.next_page_uri).to eq(nil) }
    end
  end

  describe "pagination" do
    describe "#page_size" do
      it { expect(subject.page_size).to eq(50) }
    end

    describe "#page" do
      it { expect(subject.page).to eq(0) }
    end

    describe "#start" do
      it { expect(subject.start).to eq(0) }
    end

    describe "#end" do
      it { expect(subject.end).to eq(0) }
    end
  end

  describe "#to_json" do
    subject { create(factory) }
    let(:json) { JSON.parse(subject.to_json) }

    let(:json_keys) {
      [
        "first_page_uri", "end", "previous_page_uri",
        "uri", "page_size", "start",
        "usage_records",
        "next_page_uri",
        "page"
      ]
    }

    def assert_json!
      expect(json.keys).to match_array(json_keys)
      usage_records = json["usage_records"]
      calls_usage = usage_records[0]
      calls_inbound_usage = usage_records[1]
      expect(calls_usage["category"]).to eq("calls")
      expect(calls_inbound_usage["category"]).to eq("calls-inbound")
    end

    it { assert_json! }
  end
end
