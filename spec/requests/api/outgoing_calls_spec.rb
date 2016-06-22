require 'rails_helper'

describe "/2010-04-01/Accounts/{AccountSid}/Calls" do
  let(:account) { create(:account, :with_access_token) }

  let(:account_sid) { account.sid }
  let(:user) { account.sid }
  let(:password) { account.auth_token }

  def do_request(method, path, body = {}, headers = {})
    send(method, path, body, authorization_headers(user, password).merge(headers))
  end

  def authorization_headers(user, password)
    {
      "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials(
        user, password
      )
    }
  end

  let(:params) { {} }

  before do
    do_request(:post, twilio_api_account_calls_path(account_sid), params)
  end

  context "unauthorized request" do
    context "from wrong auth token" do
      let(:password) { "wrong" }
      it { expect(response.code).to eq("401") }
    end

    context "from wrong AccountSid" do
      let(:account_sid) { "wrong" }
      it { expect(response.code).to eq("401") }
    end
  end

  context "valid request" do
    let(:outgoing_call) { account.outgoing_calls.last! }
    it { assert_valid_request! }

    def assert_valid_request!
      expect(response.code).to eq("201")
      expect(response.body).to eq(outgoing_call.to_json)
    end
  end
end
