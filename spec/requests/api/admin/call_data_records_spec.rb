require 'rails_helper'

describe "'/api/admin/call_data_records'" do
  def account_params
    super.merge(:permissions => [:manage_call_data_records])
  end

  def setup_scenario
  end

  before do
    setup_scenario
  end

  describe "POST '/'" do
    let(:params) { {} }

    def setup_scenario
      super
      post_cdr
    end

    def post_cdr
      do_request(:post, api_admin_call_data_records_path, params)
    end

    context "unauthorized request" do
      def account_params
        super.merge(:permissions => [])
      end

      it { assert_unauthorized! }
    end

    context "authorized request" do
      let(:params) { freeswitch_cdr.raw_cdr }
      let(:enqueued_job) { enqueued_jobs.first }
      let(:freeswitch_cdr) { build(:freeswitch_cdr, :busy) }

      let(:phone_call) {
        create(
          :phone_call,
          :initiated,
          :with_status_callback_url,
          :from_account_with_access_token,
          :external_id => freeswitch_cdr.uuid
        )
      }

      def setup_scenario
        stub_request(:post, phone_call.status_callback_url)
        super
      end

      def post_cdr
        perform_enqueued_jobs { super }
      end

      def assert_valid_request!
        expect(response.code).to eq("201")
        expect(phone_call.reload).to be_busy
        expect(WebMock).to have_requested(
          :post, phone_call.status_callback_url
        )
      end

      it { assert_valid_request! }
    end
  end
end
