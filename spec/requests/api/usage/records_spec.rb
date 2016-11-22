require 'rails_helper'

describe "'/api/2010-04-01/Accounts/{AccountSid}/Usage/Records'" do
  describe "GET '/'" do
    before do
      do_request(:get, api_twilio_account_usage_records_path(account_sid))
    end

    context "valid request" do
      def assert_valid_request!
        expect(response.code).to eq("200")
        expect(JSON.parse(response.body).keys).to match_array(JSON.parse(Usage::Record::Collection.new.to_json).keys)
      end

      it { assert_valid_request! }
    end
  end
end
