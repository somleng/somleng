require "rails_helper"

RSpec.describe "Call Data Records API" do
  describe "POST /api/internal/call_data_records" do
    it "creates a call data record" do
      freeswitch_cdr = build(:freeswitch_cdr, :busy)

      account = create(:account, :with_access_token)
      phone_call = create(
        :phone_call, :initiated, :with_status_callback_url,
        account: account,
        external_id: freeswitch_cdr.uuid
      )

      stub_request(:post, phone_call.status_callback_url)

      perform_enqueued_jobs do
        post(
          api_internal_call_data_records_path,
          params: freeswitch_cdr.raw_cdr,
          headers: build_authorization_headers
        )
      end

      expect(response.code).to eq("201")
      expect(phone_call.reload).to be_busy
      expect(WebMock).to have_requested(
        :post, phone_call.status_callback_url
      )
    end
  end
end
