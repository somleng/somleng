require "rails_helper"

RSpec.describe "Services", :services do
  describe "PATCH /phone_calls/:id" do
    it "updates a phone call" do
      phone_call = create(:phone_call, :outbound, :initiated)

      patch(
        services_phone_call_path(phone_call),
        params: {
          "switch_proxy_identifier" => SecureRandom.uuid
        },
        headers: build_authorization_headers("services", "password")
      )

      expect(response.code).to eq("204")
      expect(phone_call.reload).to have_attributes(
        switch_proxy_identifier: be_present
      )
    end
  end
end
