require 'rails_helper'

describe "'/api/admin/phone_calls/'" do
  def account_params
    super.merge(:permissions => [:manage_inbound_phone_calls])
  end

  def setup_scenario
  end

  before do
    setup_scenario
  end

  describe "POST '/'" do
    let(:params) { {} }

    def post_phone_call
      do_request(:post, api_admin_phone_calls_path, params)
    end

    def setup_scenario
      post_phone_call
    end

    context "wrong AuthToken" do
      let(:http_basic_auth_password) { "wrong" }
      it { assert_unauthorized! }
    end

    context "account with no permissions" do
      def account_params
        super.merge(:permissions => [])
      end

      context "unauthorized request" do
        it { assert_unauthorized! }
      end

      context "NO_ADMIN_AUTH=1" do
        def env
          {"NO_ADMIN_AUTH" => "1"}
        end

        def setup_scenario
          stub_env(env)
          super
        end

        it { assert_invalid_request! }
      end
    end

    context "authorized request" do
      let(:to) { generate(:phone_number) }
      let(:external_id) { generate(:external_id) }
      let(:from) { "2442" }

      let(:variables) {
        {
          "sip_from_host" => "103.9.189.2"
        }
      }

      let(:params) {
        {
          "To" => to,
          "From" => from,
          "ExternalSid" => external_id,
          "Variables" => variables
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
        let(:created_phone_call) { PhoneCall.find(parsed_response["sid"]) }

        def setup_scenario
          incoming_phone_number
          super
        end

        def assert_valid_request!
          expect(response.code).to eq("201")
          expect(response.headers["Location"]).to eq(api_admin_phone_call_url(created_phone_call))
          expect(created_phone_call.from).to eq(from)
          expect(created_phone_call.variables).to eq(variables)
          expect(parsed_response.keys).to match_array(JSON.parse(created_phone_call.to_internal_inbound_call_json).keys)
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

    def setup_scenario
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
