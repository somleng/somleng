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

    it "validates the caller id" do
      form = SIPTrunkForm.new(caller_id_behavior: :fallback, caller_id: nil)
      form.valid?
      expect(form.errors[:caller_id]).to be_present

      form = SIPTrunkForm.new(caller_id_behavior: :passthrough, caller_id: "12342345678")
      form.valid?
      expect(form.errors[:caller_id]).to be_present

      form = SIPTrunkForm.new(caller_id_behavior: :fallback, caller_id: "12342345678")
      form.valid?
      expect(form.errors[:sender_id]).to be_blank
    end
  end
end
