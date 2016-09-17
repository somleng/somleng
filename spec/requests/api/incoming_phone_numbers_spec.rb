require 'rails_helper'

describe "'/api/2010-04-01/Accounts/{AccountSid}/IncomingPhoneNumbers'" do
  # https://www.twilio.com/docs/api/rest/call#instance-get
  describe "GET '/{IncomingPhoneNumberSid}'" do
    let(:incoming_phone_number) { create(:incoming_phone_number, :account => account) }

    before do
      do_request(:get, api_twilio_account_incoming_phone_number_path(account_sid, incoming_phone_number))
    end

    context "valid request" do
      def assert_valid_request!
        expect(response.code).to eq("200")
        expect(response.body).to eq(incoming_phone_number.to_json)
      end

      it { assert_valid_request! }
    end
  end
end
