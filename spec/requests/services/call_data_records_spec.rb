require "rails_helper"

RSpec.describe "Services" do
  describe "POST /services/call_data_records" do
    it "creates a call data record" do
      freeswitch_cdr = file_fixture("freeswitch_cdr.json").read

      carrier = create(:carrier)
      oauth_application = create(:oauth_application, owner: carrier)
      webhook_endpoint = create(:webhook_endpoint, oauth_application: oauth_application)
      account = create(:account, :with_access_token, carrier: carrier)
      phone_call = create(
        :phone_call, :initiated, :with_status_callback_url,
        account: account,
        carrier: carrier,
        external_id: "1b17f1e5-becb-4daa-8cb8-1ec822dd4297"
      )

      stub_request(:post, phone_call.status_callback_url)
      stub_request(:post, webhook_endpoint.url)

      perform_enqueued_jobs do
        post(
          api_services_call_data_records_path,
          params: JSON.parse(freeswitch_cdr),
          headers: build_authorization_headers("services", "password")
        )
      end

      expect(response.code).to eq("204")
      expect(phone_call.reload).to be_not_answered
      expect(WebMock).to have_requested(
        :post, phone_call.status_callback_url
      )
      expect(WebMock).to have_requested(
        :post, webhook_endpoint.url
      )
    end
  end
end
