require 'rails_helper'

describe StatusCallbackNotifierJob do
  describe "#perform(phone_call_id)" do
    let(:phone_call) {
      create(
        :phone_call,
        :with_status_callback_url,
        :from_account_with_access_token,
        :not_answered,
        phone_call_attributes
      )
    }

    def phone_call_attributes
      {}
    end

    let(:asserted_request_method) { :post }
    let(:asserted_request_url) { phone_call.status_callback_url }
    let(:http_request_params) { WebMock.request_params(http_request) }
    let(:http_request) { WebMock.requests.last }

    def setup_scenario
      stub_request(asserted_request_method, asserted_request_url)
      subject.perform(phone_call.id)
    end

    before do
      setup_scenario
    end

    def assert_perform!
      expect(WebMock).to have_requested(
        asserted_request_method, asserted_request_url
      )
      expect(http_request_params["CallStatus"]).to eq("no-answer")
    end

    context "by default" do
      it { assert_perform! }
    end

    context "phone_call#status_callback_method => 'GET'" do
      def phone_call_attributes
        super.merge(:status_callback_method => "GET")
      end

      let(:asserted_request_method) { :get }
      it { assert_perform! }
    end
  end
end
