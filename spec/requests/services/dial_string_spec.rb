require "rails_helper"

RSpec.describe "Services" do
  describe "POST /services/dial_string" do
    it "generates a dial string" do
      post(
        services_dial_string_path,
        params: {
          phone_number: "85516701721"
        },
        headers: build_authorization_headers("services", "password")
      )

      expect(response.code).to eq("201")
      expect(json_response).to eq(
        "dial_string" => "016701721@27.109.112.140"
      )
    end
  end
end
