require 'rails_helper'

describe "'/api/admin/phone_calls/'" do
  def account_params
    super.merge(:permissions => [:manage_inbound_phone_calls])
  end

  describe "POST '/'" do
    let(:params) { {} }

    def setup_scenario
    end

    def post_phone_call
      do_request(:post, api_admin_phone_calls_path, params)
    end

    before do
      setup_scenario
      post_phone_call
    end

    context "unauthorized request" do
      def account_params
        super.merge(:permissions => [])
      end

      it { assert_unauthorized! }
    end

    context "authorized request" do
      let(:to) { generate(:phone_number) }
      let(:external_id) { generate(:external_id) }
      let(:from) { "2442" }

      let(:params) {
        {
          "To" => to,
          "From" => from,
          "ExternalSid" => external_id
        }
      }

      context "invalid request" do
        def assert_invalid_request!
          expect(response.code).to eq("422")
        end

        it { assert_invalid_request! }
      end

      context "valid request" do
        let(:incoming_phone_number) { create(:incoming_phone_number, :with_optional_attributes, :phone_number => to) }
        let(:parsed_response) { JSON.parse(response.body) }
        let(:phone_call) { PhoneCall.find(parsed_response["sid"]) }

        def setup_scenario
          incoming_phone_number
        end

        def assert_valid_request!
          expect(response.code).to eq("201")
          expect(phone_call.from).to eq(from)
          expect(response.body).to eq(phone_call.to_internal_inbound_call_json)
        end

        it { assert_valid_request! }
      end
    end
  end

  describe "GET '/{CallSid}'" do
    let(:phone_call) { create(:phone_call) }

    def get_phone_call
      do_request(:get, api_admin_phone_call_path(phone_call))
    end

    before do
      get_phone_call
    end

    context "unauthorized request" do
      def account_params
        super.merge(:permissions => [])
      end

      it { assert_unauthorized! }
    end

    context "valid request" do
      def assert_valid_request!
        expect(response.code).to eq("200")
        expect(response.body).to eq(phone_call.to_internal_inbound_call_json)
      end

      it { assert_valid_request! }
    end
  end
end
