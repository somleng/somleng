require 'rails_helper'

describe "'/api/2010-04-01/Accounts/{AccountSid}/Usage/Records'" do
  describe "GET '/'" do
    let(:params) { {} }

    before do
      do_request(:get, api_twilio_account_usage_records_path(account_sid, params))
    end

    context "valid request" do
      let(:sample_usage_record_collection) { build(:usage_record_collection) }

      def assert_valid_request!
        expect(response.code).to eq("200")
        expect(JSON.parse(response.body).keys).to match_array(JSON.parse(sample_usage_record_collection.to_json).keys)
      end

      it { assert_valid_request! }
    end

    context "invalid request" do
      let(:params) { { "Category" => "foobarbaz", "StartDate" => "foobarbaz", "EndDate" => "2015-01-22" } }

      def assert_invalid_request!
        expect(response.code).to eq("422")
      end

      it { assert_invalid_request! }
    end
  end
end
