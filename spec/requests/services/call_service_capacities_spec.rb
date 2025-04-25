require "rails_helper"

RSpec.describe "Services", :services do
  describe "POST /services/call_service_capacities" do
    it "updates the call service capacity" do
      post(
        api_services_call_service_capacities_path,
        params: { region: :hydrogen, capacity: 2 },
        headers: build_authorization_headers("services", "password")
      )

      expect(response.code).to eq("200")
      expect(CallServiceCapacity.current_for(:hydrogen)).to eq(2)
    end
  end
end
