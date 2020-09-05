require "rails_helper"

RSpec.describe "Services" do
  describe "POST /services/call_data_records" do
    it "creates a call data record" do
      freeswitch_cdr = file_fixture("freeswitch_cdr.json").read

      account = create(:account, :with_access_token)
      phone_call = create(
        :phone_call, :initiated, :with_status_callback_url,
        account: account,
        external_id: "1b17f1e5-becb-4daa-8cb8-1ec822dd4297"
      )

      stub_request(:post, phone_call.status_callback_url)

      perform_enqueued_jobs do
        post(
          services_call_data_records_path,
          params: JSON.parse(freeswitch_cdr),
          headers: build_authorization_headers("services", "password")
        )
      end

      expect(response.code).to eq("204")
      expect(phone_call.reload).to be_busy
      expect(WebMock).to have_requested(
        :post, phone_call.status_callback_url
      )
    end
  end
end
