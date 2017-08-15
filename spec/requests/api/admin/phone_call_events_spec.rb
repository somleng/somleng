require 'rails_helper'

describe "'/api/admin/phone_calls/:phone_call_external_id/phone_call_events'" do
  let(:phone_call) { create(:phone_call, :initiated, :with_external_id) }

  def account_params
    super.merge(:permissions => [:manage_phone_call_events])
  end

  def setup_scenario
  end

  before do
    setup_scenario
  end

  describe "GET '/:id'" do
    let(:phone_call_event) { create(:phone_call_event, :phone_call => phone_call) }

    def get_phone_call_event
      do_request(:get, api_admin_phone_call_phone_call_event_path(phone_call, phone_call_event))
    end

    def setup_scenario
      super
      get_phone_call_event
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
      end

      it { assert_valid_request! }
    end
  end

  describe "POST '/'" do
    let(:params) { {} }

    def post_phone_call_event
      do_request(:post, api_admin_phone_call_phone_call_events_path(phone_call.external_id), params)
    end

    def setup_scenario
      super
      post_phone_call_event
    end

    context "unauthorized request" do
      def account_params
        super.merge(:permissions => [])
      end

      it { assert_unauthorized! }
    end

    context "authorized request" do
      let(:event_type) { nil }
      let(:answer_epoch) { nil }
      let(:sip_term_status) { nil }

      let(:params) {
        {
          :type => event_type,
          :answer_epoch => answer_epoch,
          :sip_term_status => sip_term_status
        }
      }

      context "invalid request" do
        def assert_invalid_request!
          expect(response.code).to eq("422")
        end

        it { assert_invalid_request! }
      end

      context "valid request" do
        let(:event_type) { "completed" }
        let(:answer_epoch) { "1" }
        let(:sip_term_status) { "480" }

        let(:response_json) { JSON.parse(response.body) }

        def assert_valid_request!
          expect(response.code).to eq("201")
          expect(response_json).to have_key("phone_call")
          expect(response_json["params"]["answer_epoch"]).to eq(answer_epoch)
          expect(response_json["params"]["sip_term_status"]).to eq(sip_term_status)
          expect(response_json["phone_call"]["status"]).to eq("completed")
        end

        it { assert_valid_request! }
      end
    end
  end
end
