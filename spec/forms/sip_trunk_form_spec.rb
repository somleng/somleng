require "rails_helper"

RSpec.describe SIPTrunkForm do
  describe "validations" do
    it "validates inbound source IP" do
      form = SIPTrunkForm.new(source_ips: "96.9.66.256")

      expect(form).to be_invalid
      expect(form.errors[:source_ips]).to be_present
    end

    it "validates max channels" do
      form = SIPTrunkForm.new(max_channels: "0")

      expect(form).to be_invalid
      expect(form.errors[:max_channels]).to be_present
    end
  end
end
