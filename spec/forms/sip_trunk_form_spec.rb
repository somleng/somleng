require "rails_helper"

RSpec.describe SIPTrunkForm do
  describe "validations" do
    it "validates inbound source addresses" do
      form = SIPTrunkForm.new(source_ip_addresses: "96.9.66.18, 96.9.66.19")

      form.valid?

      expect(form.errors[:source_ip_addresses]).to be_empty

      form.source_ip_addresses = "96.9.66.18, 96.9.66.19, 96.9.66.256"

      form.valid?

      expect(form.errors[:source_ip_addresses]).to be_present
    end

    it "validates max channels" do
      form = SIPTrunkForm.new(max_channels: "0")

      expect(form).to be_invalid
      expect(form.errors[:max_channels]).to be_present
    end
  end
end
