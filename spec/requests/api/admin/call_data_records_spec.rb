require 'rails_helper'

describe "'/api/admin/call_data_records/'" do
  def account_params
    super.merge(:permissions => [:manage_call_data_records])
  end

  describe "POST '/'" do
    let(:params) { {} }

    def setup_scenario
    end

    def post_cdr
      do_request(:post, api_admin_call_data_records_path, params)
    end

    before do
      setup_scenario
      post_cdr
    end

    context "unauthorized request" do
      def account_params
        super.merge(:permissions => [])
      end

      it { assert_unauthorized! }
    end

    context "authorized request" do
      include ActiveJob::TestHelper

      let(:params) { {"some" => "cdr"}.to_json }
      let(:enqueued_job) { enqueued_jobs.first }

      def assert_valid_request!
        expect(response.code).to eq("201")
        expect(enqueued_job[:args]).to match_array([params])
      end

      it { assert_valid_request! }
    end
  end
end
