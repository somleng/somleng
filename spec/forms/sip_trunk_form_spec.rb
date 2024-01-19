require "rails_helper"

RSpec.describe SIPTrunkForm do
  describe "validations" do
    it "validates inbound source IP" do
      form = SIPTrunkForm.new(source_ip: "96.9.66.256")

      expect(form).to be_invalid
      expect(form.errors[:source_ip]).to be_present
    end

    it "validates max channels" do
      form = SIPTrunkForm.new(max_channels: "0")

      expect(form).to be_invalid
      expect(form.errors[:max_channels]).to be_present
    end

    it "validates the inbound source IP is unique" do
      create(:sip_trunk, inbound_source_ip: "96.9.66.131")
      form = SIPTrunkForm.new(source_ip: "96.9.66.131")

      expect(form).to be_invalid
      expect(form.errors[:source_ip]).to be_present
    end

    it "validates the sender pool" do
      sip_trunk = create(:sip_trunk)
      existing_phone_number = create(
        :phone_number,
        carrier: sip_trunk.carrier
      )
      other_phone_number = create(:phone_number)

      form = SIPTrunkForm.initialize_with(sip_trunk)

      form.sender_pool_phone_number_ids = [
        nil,
        existing_phone_number.id,
        other_phone_number.id
      ]

      expect(form.valid?).to eq(false)
      expect(form.errors[:sender_pool_phone_number_ids]).to be_present
    end
  end

  describe "#save" do
    it "correctly sets the sender pool phone numbers" do
      sip_trunk = create(:sip_trunk)
      phone_number_to_be_removed_from_sender_pool = create(
        :phone_number,
        number: "4444",
        sip_trunk:,
        carrier: sip_trunk.carrier
      )
      phone_number_to_be_added_to_sender_pool = create(
        :phone_number,
        number: "8888",
        carrier: sip_trunk.carrier
      )

      form = SIPTrunkForm.initialize_with(sip_trunk)
      form.sender_pool_phone_number_ids = [
        phone_number_to_be_added_to_sender_pool.id
      ]

      expect(form.save).to be_truthy
      expect(
        sip_trunk.reload.sender_pool_phone_numbers
      ).to contain_exactly(phone_number_to_be_added_to_sender_pool)
    end
  end
end
