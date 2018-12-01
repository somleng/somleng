require "rails_helper"

RSpec.describe SIPHost do
  describe ".find" do
    it "finds the SIP Host" do
      expect(described_class.find(nil)).to eq(nil)
      expect(described_class.find("")).to eq(nil)
      expect(described_class.find("27.109.112.80")).to be_a(described_class)
    end
  end

  describe "#international_dialing_code" do
    it "returns the international dialing code from the IP address" do
      stub_geocoder_request("27.109.112.80", country: "KH")
      stub_geocoder_request("200.155.77.116", country: "BR")

      expect(described_class.new("27.109.112.80").international_dialing_code).to eq("855")
      expect(described_class.new("200.155.77.116").international_dialing_code).to eq("55")
    end
  end

  def stub_geocoder_request(ip_address, response = {})
    stub_request(:get, "https://ipinfo.io/#{ip_address}/geo").to_return(
      body: response.reverse_merge(
        "ip" => ip_address,
        "country" => "KH"
      ).to_json
    )
  end
end
