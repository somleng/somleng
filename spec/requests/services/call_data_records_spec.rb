require "rails_helper"

RSpec.describe "Services", :services do
  describe "POST /services/call_data_records" do
    it "creates a call data record" do
      freeswitch_cdr = file_fixture("freeswitch_cdr.json").read

      carrier = create(:carrier)
      oauth_application = create(:oauth_application, owner: carrier)
      webhook_endpoint = create(:webhook_endpoint, oauth_application: oauth_application)
      account = create(:account, :with_access_token, carrier: carrier)
      phone_call = create(
        :phone_call, :initiated, :with_status_callback_url,
        account:,
        carrier:,
        id: "ffafbad1-9861-4522-be15-c797524bc621"
      )

      stub_request(:post, phone_call.status_callback_url)
      stub_request(:post, webhook_endpoint.url)

      perform_enqueued_jobs do
        post(
          api_services_call_data_records_path,
          params: {
            cdr: Base64.encode64(freeswitch_cdr)
          },
          headers: build_authorization_headers("services", "password").with_defaults(
            "Content-Type" => "application/x-www-form-base64-encoded"
          )
        )
      end

      expect(response.code).to eq("204")
      expect(phone_call.reload.status).to eq("completed")
      expect(WebMock).to have_requested(
        :post, phone_call.status_callback_url
      )
      expect(WebMock).to have_requested(
        :post, webhook_endpoint.url
      )
    end

    it "handles invalid json" do
      freeswitch_cdr = file_fixture("freeswitch_cdr_with_invalid_json.json").read
      phone_call = create(:phone_call, :initiated, id: "0f8fdc31-8508-4c91-be9c-2a46cf730343")

      perform_enqueued_jobs do
        post(
          api_services_call_data_records_path,
          params: {
            cdr: Base64.encode64(freeswitch_cdr)
          },
          headers: build_authorization_headers("services", "password").with_defaults(
            "Content-Type" => "application/x-www-form-base64-encoded"
          )
        )
      end

      expect(response.code).to eq("204")
      expect(phone_call.call_data_record).to have_attributes(
        bill_sec: be_present,
        duration_sec: be_present
      )
    end
  end
end
