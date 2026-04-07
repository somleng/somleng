require "rails_helper"

RSpec.describe "Services", :services do
  describe "POST /call_heartbeats" do
    it "creates call heartbeats" do
      phone_calls = create_list(:phone_call, 2, :outbound, :initiated, :with_switch_proxy_identifier)

      post(
        services_call_heartbeats_path,
        params: {
          call_ids: phone_calls.pluck(:switch_proxy_identifier)
        },
        headers: build_authorization_headers("services", "password")
      )

      expect(response.code).to eq("204")
      expect(phone_calls.map(&:reload)).to all(
        have_attributes(
          last_heartbeat_at: be_present
        )
      )
    end
  end
end
