require 'rails_helper'

describe StatusCallbackNotifierJob do
  describe "#perform(phone_call_id)" do
    let(:phone_call) { create(:phone_call, *phone_call_traits.keys, phone_call_attributes) }

    let(:phone_call_status) { "not_answered" }
    let(:call_data_record) { nil }

    def phone_call_attributes
      {
        :status => phone_call_status,
        :call_data_record => call_data_record
      }
    end

    def phone_call_traits
      {
        :with_status_callback_url => nil,
        :from_account_with_access_token => nil
      }
    end

    let(:asserted_call_status) { "no-answer" }
    let(:asserted_call_duration) { "0" }

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
      expect(http_request_params["CallStatus"]).to eq(asserted_call_status)
      expect(http_request_params["CallDuration"]).to eq(asserted_call_duration)
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

    context "phone_call#call_data_record is present" do
      let(:call_data_record) { build(:call_data_record, :bill_sec => "15") }
      let(:asserted_call_duration) { "15" }
      it { assert_perform! }
    end
  end
end
