require "rails_helper"

RSpec.describe "Services", :services do
  describe "POST /services/switch_capacities" do
    it "updates the switch capacity" do
      post(
        api_services_switch_capacities_path,
        params: { region: :hydrogen, capacity: 2 },
        headers: build_authorization_headers("services", "password")
      )

      expect(response.code).to eq("200")
      expect(SwitchCapacity.current_for(:hydrogen)).to eq(2)
    end
  end
end
